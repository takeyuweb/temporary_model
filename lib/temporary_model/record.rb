class TemporaryModel::Record < ApplicationRecord
  self.abstract_class = true

  def self.define_table(&block)
    if block_given?
      @temporary_table_definition = block
    else
      @temporary_table_definition
    end
  end
end
