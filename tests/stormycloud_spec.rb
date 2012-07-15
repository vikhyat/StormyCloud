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

  describe "#generate" do
    before(:each) do
      @sc = StormyCloud.new("127.0.0.1")
    end
    
    it "should raise NotImplementedError if no generate function is given" do
      expect { @sc.generate }.to raise_error(NotImplementedError)
    end

    it "should accept a block and save it" do
      @sc.generate { [1,2,3] }
      @sc.generate.should == [1,2,3]
    end
  end
end
