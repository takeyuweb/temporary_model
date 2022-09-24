require_relative 'boot'

require 'rails/all'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)
require "temporary_model"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
  end
end

