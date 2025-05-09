# This class is used to implement a redis cache store.
class RedisCacheStore
  # Default expiry time if not provided. (1 hour)
  DEFAULT_TTL = 3_600

  def initialize(namespace = nil, config = nil)
    unless RUBY_PLATFORM == 'java'
      require 'oj'
    end

    @connection_pool = RedisConnectionPool.new(namespace, config)

    @namespace = namespace
    @config = config

    @connections_created = 0
    @connections_in_use = 0
    @mutex = Mutex.new
    @enable_stats = false
  end

  attr_reader :connection_pool

  # This method is called to configure the connection to the cache store.
  def configure(host = 'localhost',
                port = 6379,
                db = 0,
                password = nil,
                driver: nil,
                url: nil,
                connect_timeout: 0.5,
                read_timeout: 1,
                write_timeout: 0.5)
    if !url.nil?
      @config = {}
      @config[:url] = url
      @config[:db] = db
    else
      @config = { host: host, port: port, db: db }
    end

    @config[:password] = password unless password.nil?
    @config[:driver] = driver unless driver.nil?

    @config[:connect_timeout] = connect_timeout
    @config[:read_timeout] = read_timeout
    @config[:write_timeout] = write_timeout
    connection_pool.config = @config
  end

  def clean
    connection_pool.shutdown
  end
  alias shutdown clean

  def with_client(&block)
    connection_pool.with_connection(&block)
  end

  # This method is called to set a value within this cache store by it's key.
  #
  # @param key [String] This is the unique key to reference the value being set within this cache store.
  # @param value [Object] This is the value to set within this cache store.
  # @param expires_in [Integer] This is the number of seconds from the current time that this value should expire.
  def set(key, value, expires_in = DEFAULT_TTL)
    k = build_key(key)

    v = if value.nil? || (value.is_a?(String) && value.strip.empty?)
          nil
        else
          serialize(value)
        end

    expiry_int = Integer(expires_in)
    expire_value = expiry_int.positive? ? expiry_int : Integer(DEFAULT_TTL)

    with_client do |client|
      client.multi do |pipeline|
        pipeline.set(k, v)
        pipeline.expire(k, expire_value)
      end
    end
  end

  # This method is called to get a value from this cache store by it's unique key.
  #
  # @param key [String] This is the unique key to reference the value to fetch from within this cache store.
  # @param expires_in [Integer] This is the number of seconds from the current time that this value should expire.
  # (This is used in conjunction with the block to hydrate the cache key if it is empty.)
  # @param &block [Block] This block is provided to hydrate this cache store with the value for the request key
  # when it is not found.
  # @return [Object] The value for the specified unique key within the cache store.
  def get(key, expires_in = 0)
    k = build_key(key)

    value = with_client do |client|
      client.get(k)
    end

    if !value.nil? && value.strip.empty?
      value = nil
    else
      value = deserialize(value) unless value.nil?
    end

    if value.nil? && block_given?
      value = yield
      set(key, value, expires_in)
    end

    value
  end

  # This method is called to remove a value from this cache store by it's unique key.
  #
  # @param key [String] This is the unique key to reference the value to remove from this cache store.
  def remove(key)
    with_client do |client|
      client.del(build_key(key))
    end
  end

  # This method is called to check if a value exists within this cache store for a specific key.
  #
  # @param key [String] This is the unique key to reference the value to check for within this cache store.
  # @return [Boolean] True or False to specify if the key exists in the cache store.
  def exist?(key)
    with_client do |client|
      !client.exists(build_key(key)).zero?
    end
  end

  # Ping the cache store.
  #
  # @return [String] `PONG`
  def ping
    with_client do |client|
      client.ping
    end
  end

  alias write set
  alias read get
  alias delete remove

  private

  def serialize(object)
    if RUBY_PLATFORM == 'java'
      Marshal::dump(object)
    else
      Oj.dump(object)
    end
  end

  def deserialize(object)
    if RUBY_PLATFORM == 'java'
      Marshal::load(object)
    else
      Oj.load(object)
    end
  end

  def build_key(key)
    if !@namespace.nil?
      @namespace + ':' + key.to_s
    else
      key.to_s
    end
  end
end
