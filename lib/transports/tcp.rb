require_relative "../transport.rb"
require 'socket'

class StormyCloudTCPTransport < StormyCloudTransport
  def initialize_server
    @server = TCPServer.new @stormy_cloud.config(:port)
    @server_thread = Thread.new do
      loop do
        Thread.start(@server.accept) do |client|
          client.puts handle(client.gets)
        end
      end
    end
  end

  def kill_server
    @server_thread.kill
  end

  def raw_send_message(string)
    s = TCPSocket.new(@stormy_cloud.server, @stormy_cloud.config(:port))
    s.puts string
    res = s.gets
    s.close
    res
  end
end
