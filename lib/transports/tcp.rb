require_relative "../transport.rb"
require 'socket'

class StormyCloudTCPTransport < StormyCloudTransport
  def initialize_server
  end

  def kill_server
  end

  def raw_send_message(string)
  end
end
