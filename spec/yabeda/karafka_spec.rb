# frozen_string_literal: true

RSpec.describe Yabeda::Karafka do
  it 'has a version number' do
    expect(Yabeda::Karafka::VERSION).not_to be_nil
  end

  it 'has registered all metrics' do
    expect(Yabeda.metrics.count).to eq 6
  end

  describe 'have registered metric' do

    shared_examples 'a metric' do |metric, type|
      describe metric do
          it "is a #{type.name}" do
            expect(Yabeda.metrics[metric]).to be_an_instance_of(type)
          end
        end
    end

    shared_examples 'a counter' do |metric|
      it_behaves_like 'a metric', metric, Yabeda::Counter
    end

    shared_examples 'a histogram' do |metric|
      it_behaves_like 'a metric', metric, Yabeda::Histogram
    end

    %w[
      karafka_errors_total
      karafka_consumer_received_message_total
      karafka_consumer_processed_message_total
      karafka_producer_sent_message_total
    ].each do |metric|
      include_examples 'a counter', metric
    end

    %w[
      karafka_consumer_messages_per_batch
      karafka_consumer_batch_processing_time
    ].each do |metric|
      include_examples 'a histogram', metric
    end
  end
end
