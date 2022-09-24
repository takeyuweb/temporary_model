$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require 'temporary_model/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'temporary_model'
  s.version     = TemporaryModel::VERSION
  s.authors     = ['Yuichi Takeuchi']
  s.email       = ['yuichi.takeuchi@takeyuweb.co.jp']
  s.homepage    = 'https://github.com/takeyuweb/temporary_model'
  s.summary     = 'You can define a temporary class and use it in ActiveSupport::TestCase.'
  s.description = 'You can define a temporary class and use it in ActiveSupport::TestCase.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 7.0'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sprockets-rails'
  s.add_development_dependency 'prime'
end
