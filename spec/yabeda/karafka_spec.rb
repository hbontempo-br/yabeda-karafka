# frozen_string_literal: true

RSpec.describe Yabeda::Karafka do
  it 'has a version number' do
    expect(Yabeda::Karafka::VERSION).not_to be_nil
  end

  describe 'have registered metric' do
    shared_examples 'is of type' do |metric, type|
      it "is a instance of #{type.name}" do
        expect(Yabeda.metrics[metric]).to be_an_instance_of(type)
      end
    end

    shared_examples 'has unit' do |metric, unit|
      it "has unit #{unit}" do
        expect(Yabeda.metrics[metric].unit).to eq unit
      end
    end

    shared_examples 'has tags' do |metric, tags|
      it "has tags #{tags.to_s}" do
        expect(Yabeda.metrics[metric].tags).to eq tags
      end
    end

    describe 'registered metrics' do
      it 'has registered all metrics' do
        expect(Yabeda.metrics.count).to eq 11
      end
    end

    [
      ['karafka_errors_total', nil, Yabeda::Counter, %i[type base_type error]],
      ['karafka_consumer_received_batches_total', nil, Yabeda::Counter, %i[topic partition consumer]],
      ['karafka_consumer_received_messages_total', nil, Yabeda::Counter, %i[topic partition consumer]],
      ['karafka_consumer_processed_batches_total', nil, Yabeda::Counter, %i[topic partition consumer]],
      ['karafka_consumer_processed_messages_total', nil, Yabeda::Counter, %i[topic partition consumer]],
      ['karafka_consumer_sent_messages_to_dead_letter_queue_total', nil, Yabeda::Counter, %i[topic partition consumer dlq_topic]],
      ['karafka_producer_sent_messages_total', nil, Yabeda::Counter, %i[topic type]],
      ['karafka_consumer_batch_size', nil, Yabeda::Histogram, %i[topic partition consumer]],
      ['karafka_consumer_batch_processing_time', :milliseconds, Yabeda::Histogram, %i[topic partition consumer]],
      ['karafka_consumer_message_processing_time', :milliseconds, Yabeda::Histogram, %i[topic partition consumer]],
      ['karafka_producer_message_send_time', :milliseconds, Yabeda::Histogram, %i[topic type]],

    ].each do |metric, unit, type, tags|
      describe metric do
        it_behaves_like 'is of type', metric, type
        it_behaves_like 'has unit', metric, unit
        it_behaves_like 'has tags', metric, tags
      end
    end
  end

  describe 'computes producer events' do
    def produce_messages(type)
      ::Karafka.producer.send(
        "produce_many_#{type}",
        [{ payload: 'what', topic: 'b' }, { payload: 'ever', topic: 'a' }]
      )
    end

    %w[sync async].each do |type|
      describe "when using :produce_many_#{type} method" do
        it 'computes :karafka_producer_sent_messages_total' do
          expect { produce_messages(type) }.to increment_yabeda_counter(:karafka_producer_sent_messages_total).by(2)
        end
        it 'computes :karafka_producer_message_send_time' do
          expect { produce_messages(type) }.to measure_yabeda_histogram(:karafka_producer_message_send_time)
        end
      end
    end

    def produce_message(type)
      ::Karafka.producer.send(
        "produce_#{type}",
        { payload: 'what', topic: 'b' }
      )
    end

    %w[sync async].each do |type|
      describe "when using :produce_#{type} method" do
        it 'computes :karafka_producer_sent_messages_total' do
          expect { produce_message(type) } .to increment_yabeda_counter(:karafka_producer_sent_messages_total).by(1)
        end
        it 'computes :karafka_producer_message_send_time' do
          expect { produce_message(type) } .to measure_yabeda_histogram(:karafka_producer_message_send_time)
        end
      end
    end
  end

  describe 'computes consumer events' do
  end
end
