require_relative '../lib/stormy-cloud'

describe StormyCloud do
  describe "#config" do
    it "should return the default value when nothing is set" do
      sc = StormyCloud.new("127.0.0.1")
      sc.config(:wait).should == 15
    end

    it "should check whether the given key is valid" do
      sc = StormyCloud.new("127.0.0.1")
      expect { sc.config(:invalid) }.to raise_error(ArgumentError)
    end

    it "should check the type of the value" do
      sc = StormyCloud.new("127.0.0.1")
      expect { sc.config(:wait, "invalid") }.to raise_error(ArgumentError)
    end

    it "should set the value when it is of the correct type" do
      sc = StormyCloud.new("127.0.0.1")
      sc.config(:wait).should == 15
      sc.config(:wait, 20)
      sc.config(:wait).should == 20
    end
  end
end
