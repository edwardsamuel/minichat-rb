require 'socket'
require_relative './msocket'

module Minichat
  # TCP/IP client socket implementation
  class MTCPSocket < ::Socket
    include MSocket

    def initialize(remote_host, remote_port)
      super(AF_INET, SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
      connect(Socket.pack_sockaddr_in(remote_port, remote_host))
    end
  end
end
