require 'securerandom'

# Define the basic outline of a transport, and provide serialization and stuff
# so that code doesn't have to be duplicated in every transport definition.
class StormyCloudTransport
  attr_reader :identifier
  # This method should be "extended" by the specific transports, i.e. they
  # should first call super and then perform any transport-specific
  # instantiation.
  def initialize
    # Give a unique identifier to this transport class.
    @identifier = SecureRandom.hex(32)
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
end