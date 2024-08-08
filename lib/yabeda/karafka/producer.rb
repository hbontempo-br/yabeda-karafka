# frozen_string_literal: true

require 'karafka'

module Yabeda
  module Karafka
    class Producer
      class << self
        def register_metrics
          Yabeda.configure do
            group :karafka_producer do
              counter :sent_message_total,
                      tags: %i[topic type],
                      comment: 'A counter of the total number of messages sent'
            end
          end
        end

        def register_events
          %w[sync async].each do |type|
            message_sent(type)
            message_batch_sent(type)
          end
        end

        private

        def register_event(event_name, &block)
          ::Karafka.producer.monitor.subscribe(event_name, &block)
        end

        def message_sent(type)
          register_event("message.produced_#{type}") do |event|
            message = event[:message]
            labels = { topic: message.topic, type: type }
            Yabeda.karafka_producer_sent_message_total.increment(labels)
          end
        end

        def message_batch_sent(type)
          register_event("messages.produced_#{type}") do |event|
            messages = event[:messages]
            messages.each do |message|
              labels = { topic: message.topic, type: type }
              Yabeda.karafka_producer_sent_message_total.increment(labels)
            end
          end
        end

        def error
          register_event('error.occurred') do |event|
            type = event[:type]
            base_type = type.split('.').first
            labels = { type: type, base_type: base_type }.compact
            Yabeda.karafka_errors_total.increment(labels)
          end
        end
      end
    end
  end
end
