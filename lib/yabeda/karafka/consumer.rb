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


      MESSAGE_PROCESSING_TIME_BUCKETS = [
        1, 2, 3, 4, 5, 7.5, 10, 12.5, 15, 17.5, 20, 22.5, 25, 30, 35, 40, 45,
        50, 60, 70, 80, 90, 100, 125, 150, 175, 200, 225, 250, 275, 300, 400,
        500, 600, 700, 800, 900, 1_000
      ].freeze

      MESSAGE_PER_BATCH_BUCKETS = [
        1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 75, 100, 125, 150, 200, 250, 300, 400, 500
      ].freeze

      class << self
        def register_metrics # rubocop:disable Metrics/MethodLength
          Yabeda.configure do
            group :karafka_consumer do
              counter :received_batches_total,
                      tags: %i[topic partition consumer],
                      comment: 'Total number of batches received'

              counter :received_messages_total,
                      tags: %i[topic partition consumer],
                      comment: 'Total number of messages received'

              counter :processed_batches_total,
                      tags: %i[topic partition consumer],
                      comment: 'Total number of batches processed'

              counter :processed_messages_total,
                      tags: %i[topic partition consumer],
                      comment: 'Total number of messages processed'

              histogram :batch_size,
                        per: :batch,
                        tags: %i[topic partition consumer],
                        buckets: MESSAGE_PER_BATCH_BUCKETS,
                        comment: 'Quantity of messages received per batch of messages'

              histogram :batch_processing_time,
                        unit: :milliseconds,
                        per: :batch,
                        tags: %i[topic partition consumer],
                        buckets: BATCH_PROCESSING_TIME_BUCKETS,
                        comment: 'Time that took to process a given batch of messages'

              histogram :message_processing_time,
                        unit: :milliseconds,
                        per: :batch,
                        tags: %i[topic partition consumer],
                        buckets: MESSAGE_PROCESSING_TIME_BUCKETS,
                        comment: 'Time that took to process message'
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
            Yabeda.karafka_consumer_received_batches_total.increment(labels)
            Yabeda.karafka_consumer_received_messages_total.increment(labels, by: message_count)
            Yabeda.karafka_consumer_batch_size.measure(labels, message_count)
          end
        end

        def messages_consumed
          register_event('consumer.consumed') do |event|
            consumer = event[:caller]
            messages_count = consumer.messages.count
            labels = { topic: consumer.topic.name, partition: consumer.partition, consumer: consumer.class.name }.compact
            Yabeda.karafka_consumer_processed_batches_total.increment(labels)
            Yabeda.karafka_consumer_processed_messages_total.increment(labels, by: messages_count)
            Yabeda.karafka_consumer_batch_processing_time.measure(labels, event[:time])
            Yabeda.karafka_consumer_message_processing_time.measure(labels, event[:time]/messages_count)
          end
        end

        def error
          register_event('error.occurred') do |event|
            type = event[:type]
            base_type = type.split('.').first
            error = event[:error].class.name
            labels = { type: type, base_type: base_type, error: error }.compact
            Yabeda.karafka_errors_total.increment(labels)
          end
        end
      end
    end
  end
end
