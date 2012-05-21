module Domain::AIS
  class MessageFactory
    def self.fromPayload(payload)
      decoded = SixBitEncoding.decode(payload)
      msg_type = decoded[0..5].to_i(2)
      raise "Unknown message type #{msg_type}" unless [1, 2, 3].include?(msg_type)   
      message = Message.new(decoded[8..37].to_i(2))
    end
  end
end