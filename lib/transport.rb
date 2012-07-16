require 'base64'
require 'digest'
require 'msgpack'
require 'securerandom'
require 'set'
require 'thread'

# Define the basic outline of a transport, and provide serialization and stuff
# so that code doesn't have to be duplicated in every transport definition.
class StormyCloudTransport
  attr_reader :secret, :stormy_cloud, :queue
  # This method should be "extended" by the specific transports, i.e. they
  # should first call super and then perform any transport-specific
  # instantiation.
  def initialize(stormy_cloud)
    # Generate a secret that will be used to shutdown the server.
    @secret       = SecureRandom.hex(32)
    # A hash of identifier -> time of last server access.
    @clients      = {}
    # Are we operating in server mode or client mode?
    @mode         = :server
    # Save `stormy_cloud`.
    @stormy_cloud = stormy_cloud
    # Create a new empty queue for storing sub tasks.
    @queue        = Queue.new
    # A list of tasks that are currently being worked on.
    @assigned     = []
    # A mutex to synchronize access to the queue, assigned list and completed
    # list.
    @queue_mutex  = Mutex.new
    # A set of completed tasks.
    # TODO: This needs to be synchronized with a file for persistency.
    @completed    = Set.new
  end

  # A unique identifier derived from the secret.
  def identifier
    Digest::MD5.hexdigest("Omikron" + @secret + "9861")
  end

  # Run the split method on the stormy cloud, and save the results into a
  # queue.
  def split
    @stormy_cloud.split.each {|x| @queue.push x }
  end

  # Remove tasks from the queue until we encounter one which is not on the
  # completed list. Add this task to the assigned list, and spawn a thread
  # to move it back into the queue after a timeout.
  # If the queue is empty, return a random task from the assigned list.
  # If both the queue and the assigned list are empty, return nil.
  def get
    @queue_mutex.synchronize do
      if @queue.empty?

        if @assigned.length == 0
          return nil
        else
          task = @assigned.sample
          _spawn_remover(task)
          return task
        end

      else

        task = @queue.pop
        if @completed.include? task
          return get
        else
          _spawn_remover(task)
          @assigned.push task
          return task
        end

      end
    end
  end

  # Spawn a thread that will wait for some time and then remove the task from
  # the assigned list and add it back to the queue if it is still in the 
  # assigned list.
  def _spawn_remover(task)
    Thread.new do
      sleep @stormy_cloud.config(:wait)
      @queue_mutex.synchronize do
        if @assigned.include? task
          @assigned.delete(task)
          @queue.push(task)
        end
      end
    end
  end

  # This method is used by the server to handle communication with clients.
  # It should not be overridden by specific transports. It accepts a string
  # which is a serialized command sent by the server, and returns another
  # serialized string which is the response that should be sent to the client.
  # All "commands" are basically arrays in which the first element is the
  # action and subsequent elements are parameters. _Every_ command will have
  # the identifier as its first parameter.
  #
  # The following actions are supported:
  #   HELLO(identifier)         -> get the server's identifier.
  #   KILL(identifier, secret)  -> if the secret matches the current server's
  #                                secret, switch to client mode and shut down
  #                                the server.
  #   GET(identifier)           -> get a new task from the server.
  #   PUT(identifier, task, result)
  #                             -> return the result of a task to the server.
  #
  def handle(string)
    valid_commands = ["HELLO", "KILL", "GET", "PUT"]
    command = unserialize(string)
    
    if not (command.kind_of?(Array) and valid_commands.include? command[0])
      # The command is invalid.
      return serialize("INVALID COMMAND")
    end

    # Update the time of last access.
    @clients[command[1]] = Time.now

    if    command[0] == "HELLO"

      return serialize(identifier)

    elsif command[0] == "KILL"

      if command[2] == @secret
        @mode = :client
        return serialize("OKAY")
      else
        return serialize("NOPE")
      end

    elsif command[0] == "GET"

      return serialize(get)

    elsif command[0] == "PUT"

      raise NotImplementedError

    end
  end

  # Check whether the system running this code is the one that is designated as
  # the server.
  # 1. Generate a random string.
  # 2. Create a "server" that returns the random string.
  # 3. Ask the server for the random string, and check whether it is the one
  #    that was generated earlier.
  def loopback?
    raise NotImplementedError
  end

  # Serialize a request into a string by doing MsgPack + Base64 encoding.
  # This can be overridden by the specific transport if the protocol used is
  # such that this mode of serialization is disadvantageous.
  def serialize(object)
    Base64::encode64(object.to_msgpack)
  end

  # Unserialize an object which has been serialized using the `serialize`
  # method.
  def unserialize(string)
    MessagePack.unpack(Base64::decode64(string))
  end
end
