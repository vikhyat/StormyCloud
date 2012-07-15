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
      expect { @sc.config(:debug, "invalid") }.to raise_error(ArgumentError)
    end

    it "should set the value when it is of the correct type" do
      @sc.config(:wait).should == 15
      @sc.config(:wait, 20)
      @sc.config(:wait).should == 20
      @sc.config(:debug).should == false
      @sc.config(:debug, true)
      @sc.config(:debug).should == true
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
      expect { @sc.map(23) }.to raise_error(NotImplementedError)
    end

    it "should raise ArgumentError when called without an task and block" do
      expect { @sc.map }.to raise_error(ArgumentError)
      @sc.map {|t| 42 }
      expect { @sc.map }.to raise_error(ArgumentError)
    end

    it "should accept a block and save it" do
      @sc.map { 42 }
      @sc.map(23).should == 42
    end
  end

  describe "#reduce" do
    before(:each) do
      @sc = StormyCloud.new("127.0.0.1")
    end

    it "should raise NotImplementedError when not set" do
      expect { @sc.reduce(23) }.to raise_error(NotImplementedError)
    end

    it "should raise ArgumentError when called without a result and block" do
      expect { @sc.reduce }.to raise_error(ArgumentError)
      @sc.reduce {|r| r + 50 }
      expect { @sc.reduce }.to raise_error(ArgumentError)
    end
    
    it "should accept a block and save it" do
      @sc.reduce {|r| r + 50 }
      @sc.reduce(23).should == 73
    end
  end

  describe "#finally" do
    before(:each) do
      @sc = StormyCloud.new("127.0.0.1")
    end

    it "should return nil when not defined" do
      @sc.finally.should == nil
    end

    it "should accept a block and save it" do
      @sc.finally { 42 }
      @sc.finally.should == 42
    end
  end
end
