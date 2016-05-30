require_relative './message'

module Minichat
  # Minichat socket helper to read/send message
  module MSocket
    SEPARATOR = "\n".freeze
    LIMIT = 102400 # 100K limit

    def read_message
      # gets is a Ruby native implementation to read until find a separator
      # see: http://ruby-doc.org/core/IO.html#method-i-gets
      # raw_message = gets

      # The following method is just simulating C recv method
      @buffer ||= ''
      loop do
        temp = recv(1024)
        @buffer << temp
        return nil if temp.empty?
        break if temp.include?(SEPARATOR) || @buffer.size > LIMIT
      end

      raw_message, @buffer = @buffer.split(SEPARATOR, 2)
      if raw_message
        Message.parse(raw_message.chomp)
      else
        nil
      end
    end

    def send_message(message)
      # puts is a Ruby native implementation to write a line with separator
      # see: http://ruby-doc.org/core/IO.html#method-i-gets
      # puts message

      # The following method is just simulating C recv method
      raw_message = message.to_s
      raw_message << SEPARATOR unless raw_message.end_with?(SEPARATOR)
      raise ArgumentError, 'Message can not be over 100K' if raw_message.length > LIMIT
      until raw_message.empty? do
        sent = send(raw_message, 0)
        raw_message = raw_message[sent..-1]
      end
    end
  end
end
