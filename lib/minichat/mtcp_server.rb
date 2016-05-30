require 'socket'
require_relative './msocket'

module Minichat
  # TCP/IP server socket implementation
  class MTCPServer < ::Socket
    def initialize(hostname, port)
      super(Addrinfo.ip(hostname).ipv6? ? AF_INET6 : AF_INET, SOCK_STREAM, 0)

      # To allow reuse the address (for rapid restarts of the server)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)

      # Bind socket to specified host and port
      bind(Socket.sockaddr_in(port, hostname))
      listen(5)
    end

    def accept
      client_socket, client_addrinfo = super
      client_socket.extend(MSocket)
      [client_socket, client_addrinfo]
    end
  end
end
