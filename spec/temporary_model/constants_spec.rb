require 'rails_helper'

RSpec.describe 'temporary_model', 'constants' do
  context 'Post is defined' do
    include TemporaryModel::TestHelper

    temporary_model 'Post' do
      define_table do |t|
        t.string :title, default: '', null: false
      end
      validates :title, presence: true
    end

    example { expect { 'Post'.constantize }.to_not raise_error }
  end

  context 'Post is not defined' do
    include TemporaryModel::TestHelper

    example { expect { 'Post'.constantize }.to raise_error(NameError) }
  end
end
