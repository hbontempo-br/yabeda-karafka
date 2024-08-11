# frozen_string_literal: true

require 'karafka'

module Yabeda
  module Karafka
    class Producer
      MESSAGE_TRANMISSION_TIME_BUCKETS = [
        1, 3, 5, 10, 15, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275,
        300, 350, 400, 450, 500, 550, 600, 650, 700, 800, 900, 1_000, 1_500, 2_000,
        3_000, 4_000, 5_000, 6_000, 7_000, 8_000, 9_000, 10_000
      ]

      class << self
        def register_metrics
          Yabeda.configure do
            group :karafka_producer do
              counter :sent_messages_total_count,
                      unit: :messages,
                      tags: %i[topic type],
                      comment: 'Total number of kafka messages produced'

              histogram :message_send_time,
                        unit: :milliseconds,
                        per: :message,
                        tags: %i[topic type],
                        buckets: MESSAGE_TRANMISSION_TIME_BUCKETS,
                        comment: 'Time that took to send a message (ms)'
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
            labels = { topic: message[:topic], type: type }
            Yabeda.karafka_producer_sent_messages_total_count.increment(labels)
            Yabeda.karafka_producer_message_send_time.measure(labels, event[:time])
          end
        end

        def message_batch_sent(type)
          register_event("messages.produced_#{type}") do |event|
            messages = event[:messages]
            messages_count = messages.count
            messages.each do |message|
              labels = { topic: message['topic'], type: type }
              Yabeda.karafka_producer_sent_messages_total_count.increment(labels)
              Yabeda.karafka_producer_message_send_time.measure(labels, event[:time] / messages_count)
            end
          end
        end

        def error
          register_event('error.occurred') do |event|
            type = event[:type]
            base_type = type.split('.').first
            error = event[:error].class.name
            labels = { type: type, base_type: base_type, error: error }.compact
            Yabeda.karafka_errors_total_count.increment(labels)
          end
        end
      end
    end
  end
end
