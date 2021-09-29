# frozen_string_literal: true

Redis.exists_returns_integer = false

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/1' }
end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/1' }
end
