require 'logger'
require 'socket'
require 'colorize'
require_relative '../message'
require_relative '../mtcp_socket'

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
        @server_socket = MTCPSocket.new(@server_host, @server_port)
      end

      def login
        puts 'Enter a nickname:'
        @nick_name = $stdin.gets.chomp
        message = Message.new(:login, @nick_name)
        @server_socket.send_message(message)
      end

      def send
        puts 'Type message (broadcast <text> | chat <recipient> <text>): '
        Thread.new do
          loop do
            begin
              handle_input
            rescue => e
              logger.error e.message
            end
          end
        end
      end

      def handle_input
        raw_line = $stdin.gets.chomp
        if raw_line.start_with?('broadcast ')
          _type, body = raw_line.split(' ', 2)
          message = Message.new(:broadcast, @nick_name, body)
        elsif raw_line.start_with?('chat ')
          _type, to, body = raw_line.split(' ', 3)
          message = Message.new(:chat, @nick_name, to, body)
          print_chat(message)
        elsif raw_line == 'quit'
          exit 0
        end

        if message
          @server_socket.send_message(message)
        else
          logger.error 'Bad input.'
        end
      end

      def listen
        Thread.new do
          begin
            loop do
              message = @server_socket.read_message
              if message
                handle_message(message)
              else
                logger.error 'Server is disconnected'
                exit 1
              end
            end
          rescue => e
            logger.error e.message
          end
        end
      end

      def handle_message(message)
        case message.type
        when :broadcast
          print_broadcast(message)
        when :chat
          print_chat(message)
        when :error
          print_error(message)
        when :info
          print_info(message)
        else
          logger.debug "Unknown message: #{message}"
        end
      end

      def print_info(message)
        t = "#{Time.now} | Info".colorize(:blue)
        puts "#{t}: #{message.args[0]}"
      end

      def print_error(message)
        t = "#{Time.now} | Error".colorize(:red)
        puts "#{t}: #{message.args[0]}"
      end

      def print_broadcast(message)
        t = "#{Time.now} | Broadcast from #{message.args[0]}".colorize(:green)
        puts "#{t}: #{message.args[1]}"
      end

      def print_chat(message)
        t = "#{Time.now} | #{message.args[0]} -> #{message.args[1]}"
            .colorize(:magenta)
        puts "#{t}: #{message.args[2]}"
      end
    end
  end
end
