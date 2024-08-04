# frozen_string_literal: true

require 'anyway'

module Yabeda
  module Karafka
    class Config < ::Anyway::Config
      config_name :yabeda_karafka

      # Declare consumer metrics
      attr_config consumer_metrics: true

      # Declare producer metrics
      attr_config producer_metrics: true
    end
  end
end
