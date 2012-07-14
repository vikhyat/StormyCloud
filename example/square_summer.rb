# Sample application that computes the square of the first 20 squares in a 
# distributed manner.

require "../lib/stormy-cloud"

StormyCloud.new("192.168.1.6") do |c|
  # set the time to wait for a node to return a result to 20.
  # if the node doesn't respond within this time, it is assumed to be dead.
  c.config :wait, 20
end
