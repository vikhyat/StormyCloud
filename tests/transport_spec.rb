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

  describe "#get_task" do
    before(:each) do
      @sc = StormyCloud.new("test", "localhost")
      @sc.split { [1,2,3] }
    end

    it "should get tasks" do
      t = StormyCloudTransport.new(@sc)
      t.split
      [t.get_task, t.get_task, t.get_task].sort.should == [1,2,3]
    end

    it "should return from the assigned list when the queue is empty" do
      t = StormyCloudTransport.new(@sc)
      t.split
      3.times { t.get_task }
      t.get_task.should_not == nil
    end
  end

  describe "#put_task" do
    before(:each) do
      @sc = StormyCloud.new("test", "localhost")
      @sc.split { [1] }
      @sc.reduce {|t, r| @s ||= 0; @s += 42 }
      @sc.finally { @s }
      @t = StormyCloudTransport.new(@sc)
      @t.split
    end

    it "should call reduce on each completed task once" do
      @t.get_task
      @t.put_task(1, 42)
      @t.put_task(1, 42)
      @sc.finally.should == 42
    end

    it "should call finally when the job is complete" do
      @t.get_task
      @t.put_task(1, 42)
      @sc.result.should == 42
    end
  end

  describe "#complete?" do
    it "should be true when there are no tasks" do
      sc = StormyCloud.new("test", "localhost")
      sc.split { [] }
      t = StormyCloudTransport.new(sc)
      t.split
      t.complete?.should == true
    end

    it "should be false when there are jobs in the queue or assigned list" do
      sc = StormyCloud.new("test", "localhost")
      sc.split { [1] }
      sc.reduce {|t, r| 42 }
      t = StormyCloudTransport.new(sc)
      t.split
      t.complete?.should == false
      t.get_task
      t.complete?.should == false
      t.put_task(1, 3)
      t.complete?.should == true
    end
  end

  describe "#handle" do
    it "should handle commands correctly" do
      sc = StormyCloud.new("test", "localhost")
      sc.split { [1] }
      sc.reduce {|t, r| 42 }
      t = StormyCloudTransport.new(sc)
      t.split
      {
        ["HELLO", t.identifier]               => t.identifier,
        ["GET", t.identifier]                 => 1,
        ["PUT", t.identifier, 1, 42]          => "OKAY",
        ["PUT", "invalid format"]             => "INVALID COMMAND",
      }.each do |k, v|
        t.unserialize(t.handle(t.serialize(k))).should == v
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
