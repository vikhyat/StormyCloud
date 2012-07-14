class StormyCloud
  def initialize(server)
    @server = server
    @config = {}

    yield self
  end

  # If the key is valid and the value is a `kind_of` the corresponding class,
  # set the configuration variable. Otherwise, raise an ArgumentError.
  def config(key, value)
    valid_configs = {
      :wait => Fixnum
    }
    
    if not valid_configs.keys.include? key
      raise ArgumentError.new("invalid configuration key: #{key.to_s}")
    end

    if not value.kind_of? valid_configs[keys]
      raise ArgumentError.new("invalid configuration value for #{key.to_s}")
    end

    @config[key] = value
  end
end
