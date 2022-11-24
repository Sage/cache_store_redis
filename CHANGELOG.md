# v2.2.0

* Alias `#get`, `#set`, and `#remove` to `#read`, `#write`, and `#delete`, so that `RedisCacheStore` and `OptionalRedisCacheStore` can be used anywhere that expects a `#read`, `#write`, `#delete` API e.g. `faraday-http-cache`.

# v2.1.1

* Fix handling of config passed to RedisCacheStore constructor

# v2.1.0

* Set method enforces a default TTL of `3_600` if the `expires_in` option is not provided, or is invalid.
* Set method enforces the TTL to always be an Integer.

# v2.0.0

* Dropped Support for JRuby
* Improved handling of expiry when calling `set`.
* Connection Pooling (Added in v1.1.0).
