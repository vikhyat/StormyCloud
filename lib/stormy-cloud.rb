class StormyCloud
  def initialize(server)
    @server = server
    @config = {
      :wait => 15
    }

    @generate = lambda do
      raise NotImplementedError.new("generate was not specified")
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
  def generate(&block)
    if block
      @generate = block
    else
      _generate
    end
  end

  # Actually call the block set using the generate method. Check whether the
  # value generated is actually an array before returning it, if it isn't
  # raise a TypeError.
  def _generate
    tasks = @generate.call
    if tasks.kind_of? Array
      tasks
    else
      raise TypeError, "generate should return an array"
    end
  end
end
