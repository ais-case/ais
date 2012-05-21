module Domain::AIS
  class MessageFactory
    def self.fromPayload(payload)
      decoded = SixBitEncoding.decode(payload)
      msg_type = decoded[0..5].to_i(2)
      raise "Unknown message type #{msg_type}" unless [1, 2, 3].include?(msg_type)   
      message = Message.new(decoded[8..37].to_i(2))
      message.lon = decoded[61..88].to_i(2) / 600000.0
      message.lat = decoded[89..115].to_i(2) / 600000.0
      
      message
    end
  end
end