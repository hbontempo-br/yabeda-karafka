# frozen_string_literal: true

require 'karafka'

module Yabeda
  module Karafka
    class Consumer
      LONG_RUNNING_JOB_RUNTIME_BUCKETS = [
        0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, # standard (from Prometheus)
        30, 60, 120, 300, 1800
      ].freeze

      MESSAGE_PER_BATCH_BUCKETS = [
        1, 5, 10, 15, 30, 50, 75, 100, 200
      ].freeze

      class << self
        def register
          register_metrics
          register_events
        end

        private

        def register_metrics # rubocop:disable Metrics/MethodLength
          Yabeda.configure do
            group :karafka_consumer do
              counter :received_message_total,
                      tags: %i[topic partition consumer],
                      comment: 'A counter of the total number of messages received'

              counter :processed_message_total,
                      tags: %i[topic partition consumer],
                      comment: 'A counter of the total number of messages processed'

              histogram :messages_per_batch,
                        unit: :messages,
                        per: :batch,
                        tags: %i[topic partition consumer],
                        buckets: MESSAGE_PER_BATCH_BUCKETS

              histogram :batch_processing_time,
                        unit: :milliseconds,
                        per: :batch,
                        tags: %i[topic partition consumer],
                        buckets: LONG_RUNNING_JOB_RUNTIME_BUCKETS
            end
          end
        end

        def register_events
          messages_received
          messages_consumed
          error
        end

        def register_event(event_name, &block)
          ::Karafka.monitor.subscribe(event_name, &block)
        end

        def messages_received
          register_event('consumer.consume') do |event|
            consumer = event[:caller]
            labels = { topic: consumer.topic, partition: consumer.partition, consumer: consumer.class.name }
            message_count = consumer.messages.count
            Yabeda.karafka_consumer_received_message_total.increment(labels, by: message_count)
            Yabeda.karafka_consumer_messages_per_batch.measure(labels, message_count)
          end
        end

        def messages_consumed
          register_event('consumer.consumed') do |event|
            consumer = event[:caller]
            labels = { topic: consumer.topic, partition: consumer.partition, consumer: consumer.class.name }.compact
            message_count = consumer.messages.count
            time = event[:time]
            Yabeda.karafka_consumer_processed_message_total.increment(labels, by: message_count)
            Yabeda.karafka_consumer_batch_processing_time.measure(labels, time)
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
