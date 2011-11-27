require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module RacingOnRails
  class Application < Rails::Application
    config.autoload_paths += %W( 
      #{config.root}/app/models/competitions 
      #{config.root}/app/models/observers 
      #{config.root}/app/pdfs 
      #{config.root}/app/rack 
      #{config.root}/lib
      #{config.root}/lib/results
      #{config.root}/lib/sentient_user
    )

    unless ENV["SKIP_OBSERVERS"]
      config.active_record.observers = :event_observer, :name_observer, :person_observer, :race_observer, :result_observer, :team_observer
    end

    config.time_zone = "Pacific Time (US & Canada)"

    config.encoding = "utf-8"

    config.filter_parameters += [ :password, :password_confirmation ]

    # HP's proxy, among others, gets this wrong
    config.action_dispatch.ip_spoofing_check = false
    
    config.assets.enabled = true

    config.assets.version = '1.0'

    # Ugh. Make config accessible to overrides
    @config = config

    if File.exist?("#{config.root}/local/config/environments/#{::Rails.env}.rb")
      load("#{config.root}/local/config/environments/#{::Rails.env}.rb")
    end

    # See Rails::Configuration for more options
    if File.exists?("#{config.root}/local/config/database.yml")
      paths.config.database = "#{config.root}/local/config/database.yml"
    end

    # Local config customization
    load("#{::Rails.root.to_s}/local/config/environment.rb") if File.exist?("#{::Rails.root.to_s}/local/config/environment.rb")
  end
end

class ActionView::Base
  def self.default_form_builder
    RacingOnRails::FormBuilder
  end
end
