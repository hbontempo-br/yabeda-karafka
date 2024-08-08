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

    Base.register if config.consumer_metrics || config.producer_metrics
    Consumer.register if config.consumer_metrics
    Producer.register if config.producer_metrics
  end
end
