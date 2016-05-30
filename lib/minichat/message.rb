require 'digest'

module Minichat
  # Message model.
  #
  # Message types:
  #
  # 1. <sha1-hexdigest>|login|<nick_name>
  # 1. <sha1-hexdigest>|info|<body>
  # 1. <sha1-hexdigest>|error|<body>
  # 1. <sha1-hexdigest>|broadcast|<origin_nick_name>|<body>
  # 1. <sha1-hexdigest>|chat|<origin_nick_name>|<target_nick_name>|<body>
  #
  # The <sha1-digest> is counted by performing SHA-1 for type and arguments
  # chunks.
  class Message
    attr_reader :type, :args

    def self.parse(str)
      hexdigest, type, payload = str.split('|', 3)
      raise 'Bad message' unless type

      type = type.to_sym
      case type
      when :login, :info, :error
        message = Message.new(type, payload)
      when :broadcast
        message = Message.new(type, *payload.split('|', 2))
      when :chat
        message = Message.new(type, *payload.split('|', 3))
      else
        raise 'Bad message'
      end

      raise 'Hexdigest is not match' unless message.hexdigest == hexdigest
      message
    end

    def initialize(type, *args)
      @type = type
      @args = args
    end

    def to_s
      "#{hexdigest}|#{type}|#{args.join('|')}"
    end

    def hexdigest
      @hexdigest ||= calculate_hexdigest
    end

    def calculate_hexdigest
      sha1 = Digest::SHA1.new
      sha1.update(type.to_s)
      args.each { |arg| sha1 << arg.to_s }
      sha1.hexdigest
    end
  end
end
