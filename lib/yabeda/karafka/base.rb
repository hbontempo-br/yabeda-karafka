# frozen_string_literal: true

module Yabeda
  module Karafka
    class Base
      class << self
        def register
          register_metrics
        end

        private

        def register_metrics
          Yabeda.configure do
            group :karafka do
              counter :errors_total,
                      tags: %i[type base_type],
                      comment: 'A counter of the total number of errors'
            end
          end
        end
      end
    end
  end
end
