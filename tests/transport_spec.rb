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
      t = StormyCloudTransport.new
      [ 42, "string!", [1,2,3], ["m",1,"x",3,"d"] ].each do |object|
        t.unserialize(t.serialize(object)).should == object
      end
    end
  end
end
