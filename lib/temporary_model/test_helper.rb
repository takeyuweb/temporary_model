module TemporaryModel::TestHelper
  extend ActiveSupport::Concern

  included do
    def self.temporary_classes
      @temporary_classes ||= {}
    end

    def self.temporary_model(model_name, &block)
      raise(ArgumentError, "#{model_name} has already been defined") if Object.const_defined?(model_name)
      temporary_classes[model_name] = Class.new(TemporaryModel::Record, &block)
    end
  end

  # Override ActiveSupport::TestCase#run
  # FIXME: こんなにループさせんでもできるんじゃないか？
  # FIXME: テストごとに設定じゃなくてテストクラス全体でできないかな
  def run
    self.class.temporary_classes.each do |model_name, temporary_class|
      Object.const_set(model_name, temporary_class)
      create_temporary_table temporary_class.table_name, &temporary_class.define_table
    end
    super
  ensure
    TemporaryModel::Record.connection.disable_referential_integrity do
      self.class.temporary_classes.each do |model_name, temporary_class|
        drop_temporary_table temporary_class.table_name
        Object.send(:remove_const, model_name)
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
