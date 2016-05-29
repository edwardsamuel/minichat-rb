module Minichat
  # Message model.
  #
  # Message types:
  #
  # 1. login|<nick_name>
  # 1. info|<body>
  # 1. error|<body>
  # 1. broadcast|<origin_nick_name>|<body>
  # 1. chat|<origin_nick_name>|<target_nick_name>|<body>
  #
  class Message
    attr_reader :type, :args

    def initialize(type, *args)
      @type = type
      @args = args
    end

    def to_s
      "#{type}|#{args.join('|')}"
    end

    def self.parse(str)
      type, payload = str.split('|', 2)
      raise 'Bad message' unless type

      type = type.to_sym
      case type
      when :login, :info, :error
        return Message.new(type, payload)
      when :broadcast
        return Message.new(type, *payload.split('|', 2))
      when :chat
        return Message.new(type, *payload.split('|', 3))
      else
        raise 'Bad message'
      end
    end
  end
end
