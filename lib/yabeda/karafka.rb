# frozen_string_literal: true

require 'karafka'

require 'yabeda'
require 'yabeda/karafka/version'
require 'yabeda/karafka/consumer'
require 'yabeda/karafka/producer'
require 'yabeda/karafka/config'

module Yabeda
  module Karafka
    LONG_RUNNING_JOB_RUNTIME_BUCKETS = [
      0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, # standard (from Prometheus)
      30, 60, 120, 300, 1800
    ].freeze

    MESSAGE_PER_BATCH_BUCKETS = [
      1, 5, 10, 15, 30, 50, 75, 100, 200
    ].freeze

    def self.config
      @config ||= Config.new
    end

    Consumer.register if config.consumer_metrics
    Producer.register if config.producer_metrics
  end
end
