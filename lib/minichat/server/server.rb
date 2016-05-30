require 'logger'
require 'socket'

require_relative './connection'
require_relative '../message'
require_relative '../mtcp_server'

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
        @socket = MTCPServer.new(@host, @port)
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
            begin
              connection = handle_new_connection(socket, addrinfo)
              if connection
                listen_connection(connection)
              else
                Thread.current.terminate
              end
            rescue => e
              logger.error e.message
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
          shutdown(connection)
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
          end
        end
      end

      def handle_message(connection, message)
        begin
          case message.type
          when :chat
            chat(connection, message)
          when :broadcast
            broadcast(connection, message)
          end
        rescue => e
          begin
            connection.write(:error, e.message)
          rescue => e1
            logger.error e1.message
            shutdown(connection)
          end
        end
      end

      def chat(connection, message)
        target_connection = @clients[message.args[1]]
        raise "User #{message.args[1]} " \
              'is not found or already disconnected' unless target_connection

        begin
          target_connection.write(:chat, connection.nick_name, message.args[1],
                                  message.args[2])
        rescue => e
          logger.error e.message
          shutdown(target_connection)
          raise "User #{message.args[1]} " \
                'is not found or already disconnected'
        end
      end

      def broadcast(connection, message)
        @clients.each do |_key, target_connection|
          begin
            target_connection.write(message.type, connection.nick_name,
                                    message.args[1])
          rescue => e
            logger.error e.message
            shutdown(target_connection)
          end
        end
      end

      def shutdown(connection)
        logger.info "User #{connection} is disconnected."
        @clients.delete(connection.nick_name) if connection.nick_name
        connection.close
        connection.thread.terminate
      end
    end
  end
end
