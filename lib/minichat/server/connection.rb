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
        @socket.puts message
      end

      def read
        raw_message = @socket.gets
        if raw_message
          Minichat::Server.logger.debug 'Received from ' \
            "#{nick_name}: #{raw_message}"
          Message.parse(raw_message.chomp)
        end
      end
    end
  end
end
