require 'thread'

class StormyCloud
  attr_reader :result, :name, :server

  def initialize(name, server)
    @name   = name
    @server = server
    @result = nil
    @config = {
      :wait   => 15,
      :debug  => false,
      :port   => 4312
    }

    @split    = lambda do
      raise NotImplementedError.new("split was not specified")
    end
    @map      = lambda do |t|
      raise NotImplementedError.new("map was not specified")
    end
    @reduce   = lambda do |t, r|
      raise NotImplementedError.new("reduce was not specified")
    end
    @finally  = lambda { nil }

    @reduce_mutex = Mutex.new

    if block_given?
      yield self
      run
    end
  end

  # If the key is not in a whitelist, raise an ArgumentError. Otherwise,
  # check whether a value has been given. If no value has been given, return
  # the value of that key. If a value has been given, check whether it is a
  # `kind_of` the corresponding class for that key, and if so set the
  # configuration variable to the new value. Otherwise raise an ArgumentError.
  def config(key, value=nil)
    _validate_config(key, value)

    if value.nil?
      @config[key]
    else
      @config[key] = value
    end
    
  end

  # Validate the configuration keys and values.
  def _validate_config(key, value)
    valid = {
      :wait   => Fixnum,
      :debug  => [TrueClass, FalseClass],
      :port   => Fixnum
    }

    if not valid.keys.include? key
      raise ArgumentError.new("invalid configuration key: #{key.to_s}")
    end

    if not value.nil?
      type = valid[key]
      error = false

      if type.kind_of? Array
        error = true unless type.any? {|t| value.kind_of? t }
      else
        error = true unless value.kind_of? type
      end

      if error
        raise ArgumentError.new("invalid configuration value for #{key.to_s}")
      end
    end
  end

  # When called with a block, save that block for later usage. When called
  # without a block, use the block saved earlier to generate a list of tasks.
  # Raise a TypeError if the block doesn't return an array. 
  def split(&block)
    if block
      @split = block
    else
      _split
    end
  end

  # Actually call the block set using the split method. Check whether the
  # value generated is actually an array before returning it, if it isn't
  # raise a TypeError.
  def _split
    tasks = @split.call
    if tasks.kind_of? Array
      tasks
    else
      raise TypeError, "split should return an array"
    end
  end

  # When called with a block, save the block for later user. When called
  # with a single argument, call the block saved earlier. Raise an
  # ArgumentError if called without a block and task.
  def map(task=nil, &block)
    if task.nil? and block.nil?
      raise ArgumentError, "map called without a task and block"
    end

    if block
      @map = block
    else
      @map.call(task)
    end
  end

  # When called with a block, save the block for later user. When called
  # with a single argument, call the block saved earlier. Raise an
  # ArgumentError if called without a block and task.
  def reduce(task=nil, result=nil, &block)
    if block.nil? and (task.nil? or result.nil?)
      raise ArgumentError, "reduce called without a result and block"
    end

    if block
      @reduce = block
    else
      @reduce_mutex.synchronize do
        @reduce.call(task, result)
      end
    end
  end

  # When called with a block, save it for later use. Otherwise, call the
  # block which was saved earlier.
  def finally(&block)
    if block
      @finally = block
    else
      @result = @finally.call
    end
  end

  # Run the job!
  def run
    if config(:debug)
      split.each {|t| reduce(t, map(t)) }
      @result = finally
    else
      raise NotImplementedError
    end
  end
end
