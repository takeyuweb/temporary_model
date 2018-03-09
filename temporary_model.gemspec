$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "temporary_model/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "temporary_model"
  s.version     = TemporaryModel::VERSION
  s.authors     = ["Yuichi Takeuchi"]
  s.email       = ["yuichi.takeuchi@takeyuweb.co.jp"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of TemporaryModel."
  s.description = "TODO: Description of TemporaryModel."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0.rc1"

  s.add_development_dependency "sqlite3"
end
