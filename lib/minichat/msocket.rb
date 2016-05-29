require_relative './message'

module Minichat
  # Minichat socket helper to read/send message
  module MSocket
    def read_message
      raw_message = gets
      Message.parse(raw_message.chomp) if raw_message
    end

    def send_message(message)
      puts message
    end
  end
end
