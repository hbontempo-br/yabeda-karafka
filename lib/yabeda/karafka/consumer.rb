# frozen_string_literal: true

require 'karafka'

module Yabeda
  module Karafka
    module Consumer
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
                      tags: %i[topic consumer],
                      comment: 'A counter of the total number of messages received'

              counter :processed_message_total,
                      tags: %i[topic consumer],
                      comment: 'A counter of the total number of messages processed'

              histogram :messages_per_batch,
                        unit: :messages,
                        per: :batch,
                        tags: %i[topic consumer],
                        buckets: MESSAGE_PER_BATCH_BUCKETS

              histogram :batch_processing_time,
                        unit: :milliseconds,
                        per: :batch,
                        tags: %i[topic consumer],
                        buckets: LONG_RUNNING_JOB_RUNTIME_BUCKETS
            end
          end
        end

        def register_events
          messages_received
        end

        def register_event(event_name, &block)
          ::Karafka.monitor.subscribe(event_name, &block)
        end

        def messages_received
          register_event('consumer.consume') do |_event|
            message_count = 1
            consumer = 'a'
            topic = 'b'

            Yabeda.karafka_consumer_received_message_total.increment(
              { topic: topic, consumer: consumer }, by: message_count
            )
          end
        end
      end
    end
  end
end
