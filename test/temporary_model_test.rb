require 'test_helper'

class TemporaryModel::Test < ActiveSupport::TestCase
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

  test 'You can define and use temporary classes' do
    ruby = Post.create!(title: 'Ruby')
    ruby.taggings.create!(tag: Tag.create(name: 'Programming_Language'))
    ruby.taggings.create!(tag: Tag.create(name: 'Dynamic_Typing'))

    rust = Post.create!(title: 'Rust')
    rust.taggings.create!(tag: Tag.create(name: 'Programming_Language'))
    rust.taggings.create!(tag: Tag.create(name: 'Static_Typing'))

    assert_equal 'Ruby', ruby.title
    assert_equal %w[Programming_Language Dynamic_Typing], ruby.tag_names
    assert_equal [rust], Tag.find_by(name: 'Static_Typing').posts
  end
end
