require 'digest'

module Minichat
  # Message model.
  #
  # Message formats:
  #
  # 1. <sha256-hexdigest>|login|<nick_name>
  # 1. <sha256-hexdigest>|info|<body>
  # 1. <sha256-hexdigest>|error|<body>
  # 1. <sha256-hexdigest>|broadcast|<origin_nick_name>|<body>
  # 1. <sha256-hexdigest>|chat|<origin_nick_name>|<target_nick_name>|<body>
  #
  # The <sha1-digest> is counted by performing SHA-1 for type and arguments
  # chunks.
  class Message
    attr_reader :type, :args

    def self.parse(str)
      hexdigest, type, payload = str.split('|', 3)
      raise ArgumentError, 'Bad message' unless type

      type = type.to_sym
      case type
      when :login, :info, :error
        message = Message.new(type, payload)
      when :broadcast
        message = Message.new(type, *payload.split('|', 2))
      when :chat
        message = Message.new(type, *payload.split('|', 3))
      else
        raise ArgumentError, 'Bad message'
      end

      raise ArgumentError, 'Hexdigest is not match' unless message.hexdigest == hexdigest
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
      sha256 = Digest::SHA256.new
      sha256.update(type.to_s)
      args.each { |arg| sha256 << arg.to_s }
      sha256.hexdigest
    end
  end
end
