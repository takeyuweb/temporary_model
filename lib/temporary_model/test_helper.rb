module TemporaryModel::TestHelper
  extend ActiveSupport::Concern

  included do
    def self.temporary_classes
      @temporary_classes ||= []
    end

    def self.temporary_model(model_name, &block)
      raise(ArgumentError, "#{model_name} has already been defined") if Object.const_defined?(model_name)
      klass = Class.new(TemporaryModel::Record, &block)
      Object.const_set(model_name, klass)
      temporary_classes.push(klass)
    end
  end

  # Override ActiveSupport::TestCase#run
  def run
    self.class.temporary_classes.each do |temporary_class|
      create_temporary_table temporary_class.table_name, &temporary_class.define_table
    end
    super
  ensure
    TemporaryModel::Record.connection.disable_referential_integrity do
      self.class.temporary_classes.each do |temporary_class|
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
