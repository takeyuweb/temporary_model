require 'test_helper'
require 'prime'

class PrimeNumberValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:value, ' is not a prime number.') unless Prime.prime?(record.value)
  end
end

class PrimeNumberValidator::Test < ActiveSupport::TestCase
  temporary_model 'MyNumber' do
    define_table do |t|
      t.integer :value, default: 0, null: false
    end

    validates_with PrimeNumberValidator
  end

  test 'You can test a custom validator.' do
    assert MyNumber.new(value: 1).invalid?
    assert MyNumber.new(value: 2).valid?
    assert MyNumber.new(value: 3).valid?
    assert MyNumber.new(value: 4).invalid?
  end
end
