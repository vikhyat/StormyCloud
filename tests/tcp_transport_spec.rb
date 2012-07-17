require_relative "../lib/transports/tcp.rb"

describe StormyCloudTCPTransport do
  describe "#run" do
    sc = StormyCloud.new("test", "localhost")
    t = StormyCloudTCPTransport.new(sc)
    p t.run
  end
end
