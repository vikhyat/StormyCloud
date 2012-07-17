# Sample application that computes the square of the first 20 squares in a 
# distributed manner.

require_relative "../lib/stormy-cloud"

StormyCloud.new("192.168.1.6") do |c|
  # Set the time to wait for a node to return a result to 20 seconds.
  # If the node doesn't respond within this time, it is assumed to be dead.
  # The default value is 15 seconds.
  c.config :wait, 20

  # Enable "debug" mode, which will run the entire job sequentially on a single
  # computer. This is useful for testing.
  c.config :debug, true

  # Split the problem into a number of smaller tasks which will be solved by
  # the nodes in parallel.
  c.split do
    (1..20).to_a
  end

  # Perform a single task.
  c.map do |t|
    sleep 20 # "work"
    t**2
  end

  # Reduce the results together.
  c.reduce do |t, r|
    @sum ||= 0
    @sum += r
  end

  # Print the result when it is computed.
  c.finally do
    puts @sum
  end
end
