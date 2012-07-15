require_relative '../lib/stormy-cloud'

describe StormyCloud do
  describe "#config" do
    before(:each) do
      @sc = StormyCloud.new("127.0.0.1")
    end

    it "should return the default value when nothing is set" do
      @sc.config(:wait).should == 15
    end

    it "should check whether the given key is valid" do
      expect { @sc.config(:invalid) }.to raise_error(ArgumentError)
    end

    it "should check the type of the value" do
      expect { @sc.config(:wait, "invalid") }.to raise_error(ArgumentError)
    end

    it "should set the value when it is of the correct type" do
      @sc.config(:wait).should == 15
      @sc.config(:wait, 20)
      @sc.config(:wait).should == 20
    end
  end

  describe "#split" do
    before(:each) do
      @sc = StormyCloud.new("127.0.0.1")
    end
    
    it "should raise NotImplementedError if no split function is given" do
      expect { @sc.split }.to raise_error(NotImplementedError)
    end

    it "should accept a block and save it" do
      @sc.split { [1,2,3] }
      @sc.split.should == [1,2,3]
    end

    it "should raise an error when the returned value is not an array" do
      @sc.split { "not an array" }
      expect { @sc.split }.to raise_error(TypeError)
    end
  end

  describe "#map" do
    before(:each) do
      @sc = StormyCloud.new("127.0.0.1")
    end

    it "should raise NotImplementedError when not set" do
      expect { @sc.map }.to raise_error(NotImplementedError)
    end

    it "should accept a block and save it" do
      @sc.map { 42 }
      @sc.map.should == 42
    end
  end

  describe "#reduce" do
    before(:each) do
      @sc = StormyCloud.new("127.0.0.1")
    end

    it "should raise NotImplementedError when not set" do
      expect { @sc.reduce }.should raise_error(NotImplementedError)
    end

    it "should accept a block and save it" do
      @sc.reduce {|r| r + 50 }
      @sc.reduce(23).should == 73
    end
  end
end
