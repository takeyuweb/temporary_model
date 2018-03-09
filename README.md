# TemporaryModel
You can define a temporary class and use it in ActiveSupport::TestCase.

## Usage

```ruby
class YourTest < ActiveSupport::TestCase
  include TemporaryModel::TestHelper # 1 of 2

  # 2 of 2
  temporary_model 'Post' do
    define_table do |t|
      t.string :title, default: '', null: false
    end

    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings, source: :tag

    validates :title, presence: true

    # You can use custom validators
    validates_with YourCustomValidator

    # You can use Active Storage
    has_one_attached :doc
    has_many_attached :docs 

    def tag_names
      tags.pluck(:name)
    end
  end

  test 'truthy' do
    post = Post.create!(title: 'Hello')
    assert 'Hello', post.title
  end
end
```

Please check test/*test.rb

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'temporary_model'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install temporary_model
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
