require_relative '../lib/transports.rb'

describe StormyCloudTransport do
  describe "#initialize" do
    it "should assign a random identifier" do
      t = StormyCloudTransport.new
      t.identifier.should_not == nil
    end
  end

  describe "#serialize" do
    it "should serialize several types of objects correctly" do
      
    end
  end
end
