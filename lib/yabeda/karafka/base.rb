# frozen_string_literal: true

module Yabeda
  module Karafka
    class Base
      class << self
        def register_metrics
          Yabeda.configure do
            group :karafka do
              counter :errors_total,
                      tags: %i[type base_type error],
                      comment: 'Total number of error'
            end
          end
        end
      end
    end
  end
end
