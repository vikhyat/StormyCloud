# Sample application that computes the square of the first 20 squares in a 
# distributed manner.

require "../lib/stormy-cloud"

StormyCloud.new("192.168.1.6") do |c|
  # Set the time to wait for a node to return a result to 20 seconds.
  # If the node doesn't respond within this time, it is assumed to be dead.
  # The default value is 15 seconds.
  c.config :wait, 20

  # Generate a number of sub-problems to be solved in parallel. Each task will
  # be described by a single integer which is to be squared.
  c.generate do
    (1..20).to_a
  end

  # Perform a single task.
  c.perform do |t|
    sleep 20 # "work"
    t**2
  end
end
