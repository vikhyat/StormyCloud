require_relative "../lib/transports/tcp.rb"

describe StormyCloudTCPTransport do
  describe "#run" do
    it "should run a simple task with multiple nodes" do
      job = StormyCloud.new("test", "localhost")
      job.split   { [1, 2, 3, 4, 5] }
      job.map     {|t| t**2 }
      job.reduce  {|t, r| @s ||= 0; @s += (r - t) }
      job.finally { @s }

      server_transport = StormyCloudTCPTransport.new(job)
      server_thread    = Thread.new { server_transport.run }

      5.times {
        node = StormyCloudTCPTransport.new(job.dup)
        node.mode = :client
        node.run
      }

      server_thread.join
      server_transport.result.should == 40
    end
  end
end
