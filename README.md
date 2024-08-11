
> :warning: Project still in it's beginning, API is not stable yet. <br />
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; More metrics will probably be added, some metrics might need to change. <br />
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; If you find a problem, want a feature or want to help, just reach out on the [issues]. 

# Yabeda::Karafka

[Yabeda] plugin for [Karafka] events.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'yabeda-karafka-2', require: 'yabeda/karafka'
# Then add monitoring system adapter, e.g.:
# gem 'yabeda-prometheus'
```

And then install it and it's dependencies:

    $ bundle

If you're not on Rails then configure Yabeda after your application was initialized:

```ruby
Yabeda.configure!
```

_If you're using Ruby on Rails then Yabeda will configure itself automatically!_

## Metrics

### Consumer metrics

Metrics from events generated during the consumption of kafka messages

- Total number of batches received: `karafka_consumer_received_batches_total_count` (segmented by `topic`, `partition` and `consumer`)
- Total number of messages received: `karafka_consumer_received_messages_total_count` (segmented by `topic`, `partition` and `consumer`)
- Total number of batches processed: `karafka_consumer_processed_batches_total_count` (segmented by `topic`, `partition` and `consumer`)
- Total number of messages processed: `karafka_consumer_processed_messages_total_count` (segmented by `topic`, `partition` and `consumer`)
- Quantity of messages received per batch of messages: `karafka_consumer_messages_per_batch` (segmented by `topic`, `partition` and `consumer`)
- Time that took to process a batch of messages (ms): `karafka_consumer_batch_processing_time` (segmented by `topic`, `partition` and `consumer`)
- Time that took to process message (ms): `karafka_consumer_message_processing_time` (segmented by `topic`, `partition` and `consumer`)


### Producer metrics

Metrics from events generated during the producing of new kafka messages

- Total number of kafka messages produced: `karafka_producer_sent_messages_total_count` (segmented by `topic` and `type`)
- Time that took to send a message (ms): `karafka_producer_message_send_time` (segmented by `topic` and `type`)

### Error metrics

Error metrics for error that occurred on a Karafka Producer and Consumer

- Total number of error: `karafka_errors_total_count` (segmented by `base_type`, `type` and `error`)

## Configuration

Configuration is handled by [anyway_config] gem. With it you can load settings from environment variables (upcased and prefixed with `YABEDA_KARAFKA_`), YAML files, and other sources. See [anyway_config] docs for details.

| Config key         | Type    | Default | Description                                                  |
|--------------------|---------|---------|--------------------------------------------------------------|
| `consumer_metrics` | boolean | `true`  | Defines whether this process should collect consumer metrics |
| `producer_metrics` | boolean | `true`  | Defines whether this process should collect producer metrics |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org].

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hbontempo-br/yabeda-karafka.

## License

The gem is available as open source under the terms of the [MIT License].

[Karafka]: https://github.com/karafka/karafka/ 
[Yabeda]: https://github.com/yabeda-rb/yabeda
[anyway_config]: https://github.com/palkan/anyway_config
[rubygems.org]: https://rubygems.org
[MIT License]: https://opensource.org/licenses/MIT
[issues]: https://github.com/hbontempo-br/yabeda-karafka/issues
