module TemporaryModel::TestHelper
  extend ActiveSupport::Concern

  included do
    def self.class_definitions
      @class_definitions ||= {}
    end

    def self.temporary_model(model_name, &block)
      raise(ArgumentError, "#{model_name} has already been defined") if Object.const_defined?(model_name)
      class_definitions[model_name] = block
    end
  end

  # Override ActiveSupport::TestCase#run
  # FIXME: こんなにループさせんでもできるんじゃないか？
  # FIXME: テストごとに設定じゃなくてテストクラス全体でできないかな
  def run
    temporary_classes = self.class.class_definitions.map do |model_name, class_definition|
      Class.new(TemporaryModel::Record).tap do |temporary_class|
        # 先に定数に設定しておかないと
        # https://circleci.com/gh/takeyuwebinc/takeyuweb-rails/83
        Object.const_set(model_name, temporary_class)
        temporary_class.class_eval(&class_definition)

        create_temporary_table temporary_class.table_name, &temporary_class.define_table
      end
    end
    super
  ensure
    TemporaryModel::Record.connection.disable_referential_integrity do
      temporary_classes.each do |temporary_class|
        drop_temporary_table temporary_class.table_name
        Object.send(:remove_const, temporary_class.name)
      end
    end
  end

  private

    def create_temporary_table(table_name, &block)
      migration = ActiveRecord::Migration::Current.new
      migration.verbose = false
      migration.create_table(table_name, &block)
    end

    def drop_temporary_table(table_name)
      migration = ActiveRecord::Migration::Current.new
      migration.verbose = false
      migration.drop_table(table_name)
    end

end
