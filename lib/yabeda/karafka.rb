# frozen_string_literal: true

require 'karafka'
require 'yabeda'

require 'yabeda/karafka/version'
require 'yabeda/karafka/config'

require 'yabeda/karafka/base'
require 'yabeda/karafka/consumer'
require 'yabeda/karafka/producer'

module Yabeda
  module Karafka
    def self.config
      @config ||= Config.new
    end

    Base.register_metrics if config.consumer_metrics || config.producer_metrics
    Consumer.register_metrics if config.consumer_metrics
    Producer.register_metrics if config.producer_metrics

    ::Karafka.monitor.subscribe('app.initialized') do |_event|
      Consumer.register_events if config.consumer_metrics
      Producer.register_events if config.producer_metrics
    end
  end
end
