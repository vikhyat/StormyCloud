StormyCloud
-----------

**Goal:** Make it _ridiculously_ easy to write simple distributed application
in Ruby.

Installation
------------

**Todo** Package this as a gem.

Usage
-----

Here's an example that will compute the sum of the squares of the first 1000
numbers:

```ruby
StormyCloud.new("square_summation", "10.6.2.213") do |c|

  c.split { (1..1000).to_a }

  c.map do |t|
    sleep 2   # do some work
    t ** 2
  end

  c.reduce do |t, r|
    @sum ||= 0
    @sum += r
  end

  c.finally do
    puts @sum
  end

end
```

You _must_ specify the three blocks, `split`, `map` and `reduce`. The `finally`
block is optional, and will be called when the job is completed.

The `split` function must return an array of smaller sub-tasks which can be
completed in parallel.

The `map` function must take one of these sub-tasks as input and return the
result of the computation.

The `reduce` block is called once for each task and its result.

`split`, `reduce` and `finally` will be run on a central server, but `map` will
be run on worker nodes.

Configuration
-------------

Some configuration variables can be set inside the block, as shown below:

```ruby
StormyCloud.new("square_summation", "10.6.2.213") do |c|
  c.config :wait, 20
  c.config :port, 9861
  c.config :debug, true

  [...]
end
```

Currently, the only supported configuration variables are:

  * **wait**: Amount of time to wait for a result from the node before
returning a task to the node.
  * **port**: When using the TCP transport, this is the TCP port used on the
server.
  * **debug**: When this is set to true, the entire task will be run on a
single machine sequentially.

Running a Job
-------------

Running a job is as simple as copying a file onto the nodes and running a
command.

First, make sure that the machine that will act as the central server and the
ones which will be nodes all have Ruby installed along with the gem. Also make
sure the script contains the correct IP address of the actual server.

Start the server by running:

    $ ruby job.rb server

Then log in to each of the nodes and run the following commands:

    $ ruby job.rb node

When the server is run, a HTTP server will be spawned on that machine on port
4567, which can be used to track the progress of the job. It will show the
connected nodes, currently assigned tasks the estimated time to completion.
