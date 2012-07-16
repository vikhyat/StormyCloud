require_relative '../lib/transport.rb'

describe StormyCloudTransport do
  describe "#initialize" do
    it "should assign a random identifier" do
      t = StormyCloudTransport.new(StormyCloud.new("test", "localhost"))
      t.secret.should_not == nil
      t.identifier.should_not == nil
    end
  end

  describe "#serialize" do
    it "should serialize several types of objects correctly" do
      t = StormyCloudTransport.new(StormyCloud.new("test", "localhost"))
      [ 42, "string!", [1,2,3], ["m",1,"x",3,"d"] ].each do |object|
        t.unserialize(t.serialize(object)).should == object
      end
    end
  end

  describe "#split" do
    it "should create a queue with tasks" do
      sc = StormyCloud.new("test", "localhost")
      sc.split { [1, 2, 3] }
      t = StormyCloudTransport.new(sc)
      t.split
      arr = []
      3.times { arr.push t.queue.pop }
      arr.sort.should == [1, 2, 3]
    end
  end
end
