# Define the basic outline of a transport, and provide serialization and stuff
# so that code doesn't have to be duplicated in every transport definition.

class StormyCloudTransport
  # Check whether the system running this code is the one that is designated as
  # the server.
  # 1. Generate a random string.
  # 2. Create a "server" that returns the random string.
  # 3. Ask the server for the random string, and check whether it is the one
  #    that was generated earlier.
  def loopback?
    raise NotImplementedError
  end
end
