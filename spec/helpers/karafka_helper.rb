# frozen_string_literal: true

module Karafka
  # Configuration for test env
  class App
    setup do |config|
      config.kafka = { 'bootstrap.servers': '127.0.0.1:9092' }
      config.client_id = rand.to_s
      config.pause_timeout = 1
      config.pause_max_timeout = 1
      config.pause_with_exponential_backoff = false
    end
  end
end

RSpec.configure do |config|
  config.after do
    Karafka::App.routes.clear
    Karafka.monitor.notifications_bus.clear
    Karafka::App.config.internal.routing.activity_manager.clear
    Karafka::Processing::InlineInsights::Tracker.clear
  end
end