RacingOnRails::Application.configure do
  config.cache_classes = true
  config.whiny_nils = true
  config.active_support.deprecation = :stderr

  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = true

  config.action_controller.allow_forgery_protection    = false
  config.action_mailer.delivery_method = :test
end
