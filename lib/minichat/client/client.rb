require 'logger'
require 'socket'
require_relative '../message'

module Minichat
  # Minichat client
  module Client
    # Minichat client implementation
    class Client
      attr_reader :server_host, :server_port, :logger

      def initialize(server_host = '127.0.0.1', server_port = 3000)
        @server_host = server_host
        @server_port = server_port
        @logger = Logger.new(STDOUT)
      end

      def run
        connect_to_server
        listen_thread = listen
        login
        send_thread = send
        send_thread.join
        listen_thread.join
      end

      protected

      def connect_to_server
        # Create TCP Connection, IPv4
        @server_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
        @server_socket.connect(
          Socket.pack_sockaddr_in(@server_port, @server_host)
        )
      end

      def login
        puts 'Enter a nickname:'
        message = Message.new(:login, $stdin.gets.chomp)
        @server_socket.puts(message)
      end

      def listen
        Thread.new do
          loop do
            message = Message.parse @server_socket.gets.chomp
            if message
              logger.debug message
            else
              logger.error 'Bad message'
              exit 1
            end
          end
        end
      end

      def send
        puts 'Type message:'
        Thread.new do
          loop do
            message = Message.parse($stdin.gets.chomp)
            @server_socket.puts(message)
          end
        end
      end
    end
  end
end
