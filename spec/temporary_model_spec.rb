require 'rails_helper'

RSpec.describe 'temporary_model' do
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

  let(:ruby) { Post.create!(title: 'Ruby') }
  let(:rust) { Post.create!(title: 'Rust') }

  before do
    ruby.taggings.create!(tag: Tag.create(name: 'Programming_Language'))
    ruby.taggings.create!(tag: Tag.create(name: 'Dynamic_Typing'))

    rust.taggings.create!(tag: Tag.create(name: 'Programming_Language'))
    rust.taggings.create!(tag: Tag.create(name: 'Static_Typing'))
  end

  example 'You can define and use temporary classes' do
    expect(ruby.title).to eq 'Ruby'
  end

  example 'Of course you can also use relation' do
    expect(ruby.tag_names).to contain_exactly('Programming_Language', 'Dynamic_Typing')
    expect(Tag.find_by(name: 'Static_Typing').posts).to match_array([rust])
  end
end
