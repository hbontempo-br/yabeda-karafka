# Yabeda::Karafka

[Yabeda] plugin for [Karafka] events.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'yabeda-karafka'
# Then add monitoring system adapter, e.g.:
# gem 'yabeda-prometheus'
```

And then execute:

    $ bundle

If you're not on Rails then configure Yabeda after your application was initialized:

```ruby
Yabeda.configure!
```

_If you're using Ruby on Rails then Yabeda will configure itself automatically!_

## Metrics

### Consumer metrics

### Producer metrics


## Configuration

Configuration is handled by [anyway_config] gem. With it you can load settings from environment variables (upcased and prefixed with `YABEDA_KARAFKA_`), YAML files, and other sources. See [anyway_config] docs for details.

| Config key         | Type    | Default | Description                                                  |
|--------------------|---------|---------|--------------------------------------------------------------|
| `consumer_metrics` | boolean | `true`    | Defines whether this process should collect consumer metrics |
| `producer_metrics` | boolean | `true`    | Defines whether this process should collect producer metrics |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org].

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hbontempo-br/yabeda-karafka.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[Karafka]: https://github.com/karafka/karafka/ 
[Yabeda]: https://github.com/yabeda-rb/yabeda
[anyway_config]: https://github.com/palkan/anyway_config
[rubygems.org]: https://rubygems.org
