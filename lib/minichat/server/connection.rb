module Minichat
  module Server
    # Client connection
    class Connection
      attr_reader :nick_name, :socket, :thread

      def initialize(nick_name, socket, thread)
        @nick_name = nick_name
        @socket = socket
        @thread = thread
      end

      def to_s
        nick_name
      end

      def close
        @socket.close
      end

      def write(type, *args)
        message = Message.new(type, *args)
        Minichat::Server.logger.debug "Sending to #{nick_name}: #{message}"
        @socket.send_message message
      end

      def read
        message = @socket.read_message
        Minichat::Server.logger.debug 'Received from ' \
          "#{nick_name}: #{message}" if message
        message
      end
    end
  end
end
