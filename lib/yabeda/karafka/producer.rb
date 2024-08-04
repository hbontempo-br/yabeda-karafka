# frozen_string_literal: true

require 'karafka'

module Yabeda
  module Karafka
    module Producer
      class << self
        def register
          register_metrics
          register_events
        end

        private

        def register_metrics
          Yabeda.configure do
            group :karafka_producer do
              counter :sent_message_total,
                      tags: %i[topic],
                      comment: 'A counter of the total number of messages sent'
            end
          end
        end

        def register_events
          message_sent
        end

        def register_event(event_name, &block)
          ::WaterDrop.monitor.subscribe(event_name, &block)
        end

        def message_sent; end
      end
    end
  end
end
