# frozen_string_literal: true

require 'karafka'

module Yabeda
  module Karafka
    class Consumer
      BATCH_PROCESSING_TIME_BUCKETS = [
        1, 3, 5, 10, 15, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275,
        300, 350, 400, 450, 500, 550, 600, 650, 700, 800, 900, 1_000, 1_500, 2_000,
        3_000, 4_000, 5_000, 6_000, 7_000, 8_000, 9_000, 10_000
      ].freeze

      MESSAGE_PER_BATCH_BUCKETS = [
        1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 75, 100, 125, 150, 200, 250, 300, 400, 500
      ].freeze

      class << self
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
                        buckets: MESSAGE_PER_BATCH_BUCKETS,
                        comment: 'Quantity of messages on a given batch'

              histogram :batch_processing_time,
                        unit: :milliseconds,
                        per: :batch,
                        tags: %i[topic partition consumer],
                        buckets: BATCH_PROCESSING_TIME_BUCKETS,
                        comment: 'Time that took to process a given batch (ms)'
            end
          end
        end

        def register_events
          messages_received
          messages_consumed
          error
        end

        private

        def register_event(event_name, &block)
          ::Karafka.monitor.subscribe(event_name, &block)
        end

        def messages_received
          register_event('consumer.consume') do |event|
            consumer = event[:caller]
            labels = { topic: consumer.topic.name, partition: consumer.partition, consumer: consumer.class.name }
            message_count = consumer.messages.count
            Yabeda.karafka_consumer_received_message_total.increment(labels, by: message_count)
            Yabeda.karafka_consumer_messages_per_batch.measure(labels, message_count)
          end
        end

        def messages_consumed
          register_event('consumer.consumed') do |event|
            consumer = event[:caller]
            labels = { topic: consumer.topic.name, partition: consumer.partition, consumer: consumer.class.name }.compact
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
