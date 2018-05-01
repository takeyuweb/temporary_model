require 'rails_helper'

RSpec.describe 'temporary_model', 'nesting' do
  include TemporaryModel::TestHelper

  temporary_model 'Tag' do
    define_table do |t|
      t.string :name, default: '', null: false
    end

    has_many :taggings, dependent: :destroy
    has_many :posts, through: :taggings, source: :taggable, source_type: 'Post'

    validates :name, presence: true
  end

  temporary_model 'Post' do
    define_table do |t|
      t.string :title, default: '', null: false
    end

    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings, source: :tag

    validates :title, presence: true

    def tag_names
      tags.pluck(:name)
    end
  end

  temporary_model 'Tagging' do
    define_table do |t|
      t.references :tag, foreign_key: true
      t.references :taggable, polymorphic: true
    end

    belongs_to :tag
    belongs_to :taggable, polymorphic: true
  end

  context do
    temporary_model 'Author' do
      define_table do |t|
        t.string :name, default: '', null: false
        t.references :post, class_name: 'Post'
      end

      belongs_to :post
    end

    let(:post) { Post.create!(title: 'Hello') }

    before { Author.create!(name: 'Taro', post: post) }

    example { expect(Author.find_by(name: 'Taro').post).to eq post }
  end
end
