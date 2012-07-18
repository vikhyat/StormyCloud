# The problem is as follows:
# Find the number of solutions of the equation (x + y)^n = x^n + y^n,
# within the following bounds:
#   1 <= n <= 10
#   |x| <= 10
#   |y| <= 10
#   x, y, n are integers.
#

require 'stormy-cloud'

StormyCloud.new("equation_solver", "192.168.1.2") do
  c.config :debug, true

  # Split the problem on the basis of the value of n.
  c.split { (1..10).to_a }

  c.map do |n|
    count = 0
    for x in (-10)..10
      for y in (-10)..10
        count += 1 if (x + y)**n == x**n + y**n
      end
    end
    count
  end

  c.reduce do |t, r|
    @count ||= 0
    @count += r
  end

  c.finally { @count }
end
