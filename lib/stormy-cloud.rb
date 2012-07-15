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

  def generate(&block)
    if block
    else
      @generate.call
    end
  end
end
