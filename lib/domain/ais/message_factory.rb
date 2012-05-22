module Domain::AIS
  class MessageFactory
    def self.fromPayload(payload)
      decoded = SixBitEncoding.decode(payload)
      msg_type = decoded[0..5].to_i(2)
      raise "Unknown message type #{msg_type}" unless [1, 2, 3].include?(msg_type)   
      message = Message.new(Datatypes::Int.from_bit_string(decoded[8..37]).value)
      lon = Datatypes::Int.from_bit_string(decoded[61..88])
      lat = Datatypes::Int.from_bit_string(decoded[89..115])
      message.lon = lon.value / 600000.0
      message.lat = lat.value / 600000.0
      message
    end
  end
end