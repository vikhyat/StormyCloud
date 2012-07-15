class StormyCloud
  def initialize(server)
    @server = server
    @config = {
      :wait => 15
    }

    @split  = lambda do
      raise NotImplementedError.new("split was not specified")
    end
    @map    = lambda do
      raise NotImplementedError.new("map was not specified")
    end
    @reduce = lambda do |r|
      raise NotImplementedError.new("reduce was not specified")
    end


    if block_given?
      yield self
    end
  end

  # If the key is not in a whitelist, raise an ArgumentError. Otherwise,
  # check whether a value has been given. If no value has been given, return
  # the value of that key. If a value has been given, check whether it is a
  # `kind_of` the corresponding class for that key, and if so set the
  # configuration variable to the new value. Otherwise raise an ArgumentError.
  def config(key, value=nil)
    valid_configs = {
      :wait => Fixnum
    }

    if not valid_configs.keys.include? key
      raise ArgumentError.new("invalid configuration key: #{key.to_s}")
    end

    if value.nil?
      return @config[key]
    end

    if not value.kind_of? valid_configs[key]
      raise ArgumentError.new("invalid configuration value for #{key.to_s}")
    end

    @config[key] = value
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

  def map(&block)
    if block
      @map = block
    else
      @map.call
    end
  end

  def reduce(result=nil, &block)
    if block.nil? and result.nil?
      raise ArgumentError, "reduce called without a result and block"
    end

    if block
      @reduce = block
    else
      @reduce.call(result)
    end
  end
end
