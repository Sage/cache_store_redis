# CacheStoreRedis

Welcome to CacheStore!

This is the redis implementation for cache_store.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cache_store_redis'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install cache_store_redis
```

## Environment Variables

 - **CACHE_STORE_POOL_SIZE** [Integer] [Default=10] This is the max number of cache_store connections to redis to allow in the connection pool.
 - **CACHE_STORE_POOL_TIMEOUT** [Integer] [Default=1] This is the max number of seconds to wait for a connection from the pool before a timeout occurs.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sage/cache_store_redis. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

Cache Store is available as open source under the terms of the
[MIT licence](LICENSE).

Copyright (c) 2018 Sage Group Plc. All rights reserved.

