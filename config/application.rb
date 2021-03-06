require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'susy'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Haml::Filters
  remove_filter("Markdown") #remove the existing Markdown filter
  module Markdown
    include Haml::Filters::Base

    def render(text)
      Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(fenced_code_blocks: true)).render(text)
    end
  end
end

module Cinnamonroll
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # config.generators do |g|
    #   g.orm :mongoid
    # end
    # config.autoload_paths << Rails.root.join('vendor/assets')
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('vendor')
    config.autoload_paths << Rails.root.join('app', 'workers')
    # config.eager_load_paths += ["#{Rails.root}/lib}"]
    Mongoid.logger.level = Logger::INFO
    config.active_job.queue_adapter = :sidekiq
    ActionMailer::Base.default from: "markaligbe.com <bot.markaligbe+noreply@gmail.com>", return_path: 'bot.markaligbe+noreply@gmail.com'

    eval File.read(Rails.root.join('config', 'redis_config.rb'))

  end
end
