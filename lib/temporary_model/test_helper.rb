module TemporaryModel::TestHelper
  extend ActiveSupport::Concern

  included do
    class_attribute :_temporary_class_definitions, instance_accessor: false, instance_predicate: false

    def self.temporary_class_definitions
      parent_definitions = defined?(super) ? super : {}
      self._temporary_class_definitions.nil? ? parent_definitions : parent_definitions.merge(self._temporary_class_definitions)
    end

    def self.temporary_model(model_name, &block)
      raise(ArgumentError, "#{model_name} has already been defined") if Object.const_defined?(model_name)
      self._temporary_class_definitions ||= {}
      self._temporary_class_definitions[model_name] = block
    end
  end

  def before_setup
    @temporary_classes = self.class.temporary_class_definitions.map do |model_name, class_definition|
      Class.new(TemporaryModel::Record).tap do |temporary_class|
        # 先に定数に設定しておかないと
        # https://circleci.com/gh/takeyuwebinc/takeyuweb-rails/83
        Object.const_set(model_name, temporary_class)

        temporary_class.class_eval(&class_definition)
        create_temporary_table(temporary_class.table_name, &temporary_class.define_table)
      end
    end

    super
  end

  def after_teardown
    super
    if @temporary_classes.any?
      TemporaryModel::Record.connection.disable_referential_integrity do
        @temporary_classes.each do |temporary_class|
          drop_temporary_table temporary_class.table_name
          Object.send(:remove_const, temporary_class.name)
        end
      end
      # テンポラリクラスでリレーションを使っている場合、
      # ActiveSupport::Dependencies.clear をしないとリレーションのklassに再利用され、
      #
      #   Post == Tag.find_by(name: 'Tag').posts.klass # => false
      #
      # になる
      ActiveSupport::Dependencies.clear
      @temporary_classes.clear
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
