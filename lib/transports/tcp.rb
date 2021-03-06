require_relative "../transport.rb"
require 'socket'

class StormyCloudTCPTransport < StormyCloudTransport
  def initialize_server
    @server = TCPServer.new @stormy_cloud.config(:port)
    @server_thread = Thread.new do
      loop do
        Thread.start(@server.accept) do |client|
          message = ''
          while (t = client.gets).strip != "ENDOFTHEMESSAGE"
            message += t
          end
          reply = handle(message)
          client.puts reply
        end
      end
    end
  end

  def kill_server
    @server_thread.kill
  end

  def raw_send_message(string)
    begin
      s = TCPSocket.new(@stormy_cloud.server, @stormy_cloud.config(:port))
      s.puts string
      s.puts "ENDOFTHEMESSAGE"
      res = s.gets
      s.close
      res
    rescue
      @errors ||= 0
      @errors += 1
      if @errors <= 5
        STDERR.puts "An error occurred while contacting the server, trying again."
        sleep 1
        raw_send_message(string)
      else
        STDERR.puts "Could not contact the server, exiting."
        exit
      end
    end
  end
end
