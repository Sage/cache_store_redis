# This class is used to define a pool of re-usable redis connections.
class RedisConnectionPool
  attr_accessor :config

  def initialize(namespace = nil, config = nil)
    @namespace = namespace
    @config = config
    @queue = Queue.new
    @connections = []
    @mutex = Mutex.new
    @monitor_thread = Thread.new do
      loop do
        sleep(1)
        @mutex.synchronize do
          connections.select { |con| con.expired? }.each do |con|
            con.close
          end
        end
      end
    end
  end

  # This method is called to get the namespace for redis keys.
  attr_reader :namespace

  # This method is called to get the idle connection queue for this pool.
  attr_reader :queue

  # This method is called to fetch a connection from the queue or create a new connection if no idle connections
  # are available.
  def fetch_connection
    queue.pop(true)
  rescue StandardError
    RedisConnection.new(config)
  end

  # This method is called to checkout a connection from the pool before use.
  def check_out
    connection = nil
    @mutex.synchronize do
      connection = fetch_connection
      connections.delete(connection)
      connection.open
    end
    connection
  end

  # This method is called to checkin a connection to the pool after use.
  def check_in(connection)
    connection.close if connection.expired?
    @mutex.synchronize do
      connections.push(connection)
      queue.push(connection)
    end
  end

  # This method is called to use a connection from this pool.
  def with_connection
    connection = check_out
    yield connection.client
  ensure
    check_in(connection) if connection
  end

  # This method is called to get an array of idle connections in this pool.
  attr_reader :connections

  def shutdown
    connections.each do |con|
      con.client.close
    end
    @connections = []
    @monitor_thread.kill
    @queue = Queue.new
  end
end
