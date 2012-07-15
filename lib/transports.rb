require 'securerandom'
require 'digest'
require 'base64'
require 'msgpack'

# Define the basic outline of a transport, and provide serialization and stuff
# so that code doesn't have to be duplicated in every transport definition.
class StormyCloudTransport
  attr_reader :secret
  # This method should be "extended" by the specific transports, i.e. they
  # should first call super and then perform any transport-specific
  # instantiation.
  def initialize
    # Generate a secret that will be used to shutdown the server.
    @secret     = SecureRandom.hex(32)
    # A hash of identifier -> time of last server access.
    @clients    = {}
    # Are we operating in server mode or client mode?
    @mode       = :server
  end

  # A unique identifier derived from the secret.
  def idenfifier
    Digest::MD5.hexdigest("Omikron" + @secret + "9861")
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
  #   HELLO(identifier) -> get the server's identifier.
  #
  def handler(string)
    valid_commands = ["HELLO"]
    command = unserialize(string)
    
    if (not command.kind_of?(Array)) or valid_commands.include? command[0]
      return serialize("NOPE")
    end

    @clients[command[1]] = Time.now
    if command[0] == "HELLO"
      # Return the server's identifier.
      return serialize(identifier)
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
