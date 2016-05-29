require 'logger'
require 'socket'

require_relative './connection'
require_relative '../message'

module Minichat
  # Minichat server
  module Server
    def self.logger
      @logger ||= Logger.new(STDOUT)
    end

    # Minichat server implementation
    class Server
      attr_reader :host, :port, :logger

      def initialize(host = '127.0.0.1', port = 3000)
        @host = host
        @port = port
        @logger = Minichat::Server.logger
        @clients = {}
      end

      def run
        start_server
        handle_at_exit
        accept_clients
      end

      protected

      def start_server
        logger.info "Starting Minichat Server on #{host}:#{port}"

        # Create TCP Connection, IPv4
        @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)

        # To allow reuse the address (for rapid restarts of the server)
        @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)

        # Bind socket to specified host and port
        @socket.bind(Socket.sockaddr_in(@port, @host))
        @socket.listen(5)
      end

      def handle_at_exit
        at_exit do
          logger.info 'Stopping server'
          @socket.close if @socket
          exit 0
        end
      end

      def accept_clients
        loop do
          Thread.start(@socket.accept) do |socket, addrinfo|
            connection = handle_new_connection(socket, addrinfo)
            if connection
              listen_connection(connection)
            else
              Thread.current.terminate
            end
          end
        end
      end

      def handle_new_connection(socket, addrinfo)
        logger.debug 'Incoming Connection from ' \
                     "#{addrinfo.ip_address}:#{addrinfo.ip_port}"
        message = Message.parse(socket.gets.chomp)
        login(socket, message)
      end

      def login(socket, message)
        nick_name = message.args[0]
        if @clients.key?(nick_name)
          logger.debug "#{nick_name} is taken"
          connection = Connection.new(nil, socket, Thread.current)
          connection.write(:error, "#{nick_name} is already taken")
          return nil
        end
        save_connection(nick_name, socket)
      end

      def save_connection(nick_name, socket)
        connection = Connection.new(nick_name, socket, Thread.current)
        logger.info "User #{connection} is connected."
        connection.write(:info, "Welcome #{nick_name}")
        @clients[nick_name] = connection
        connection
      end

      def listen_connection(connection)
        loop do
          message = connection.read
          if message
            handle_message(connection, message)
          else
            shutdown(connection)
            Thread.current.terminate
          end
        end
      end

      def handle_message(connection, message)
        case message.type
        when :chat
          chat(connection, message)
        when :broadcast
          broadcast(connection, message)
        end
      rescue => e
        connection.write(:error, e.message)
      end

      def chat(connection, message)
        target = @clients[message.args[1]]
        raise "User #{connection.nick_name} " \
              'is not found or already disconnected' unless target
        target.write(:chat, connection.nick_name, message.args[1],
                     message.args[2])
      end

      def broadcast(connection, message)
        @clients.each do |_key, target_connection|
          target_connection.write(message.type, connection.nick_name,
                                  message.args[1])
        end
      end

      def shutdown(connection)
        logger.info "User #{connection} is disconnected."
        @clients.delete(connection.nick_name)
        connection.close
      end
    end
  end
end
