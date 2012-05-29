require_relative 'six_bit_encoding'
require_relative 'datatypes'
require_relative 'message1'
require_relative 'message5'

module Domain
  module AIS
    class MessageFactory
      def self.fromPayload(payload)
        decoded = SixBitEncoding.decode(payload)
        msg_type = decoded[0..5].to_i(2)
        raise "Unknown message type #{msg_type}" unless [1, 2, 3].include?(msg_type)
        if decoded.length == 168
          message = Message1.new(Datatypes::Int.from_bit_string(decoded[8..37]).value)
          lon = Datatypes::Int.from_bit_string(decoded[61..88])
          lat = Datatypes::Int.from_bit_string(decoded[89..115])
          message.lon = lon.value / 600000.0
          message.lat = lat.value / 600000.0
          message
        else
          nil
        end
      end
      
      def create_position_report(vessel)
        message = Message1.new(vessel.mmsi)
        message.lon = vessel.position.lon
        message.lat = vessel.position.lat
        message
      end

      def create_static_info(vessel)
        message = Message5.new(vessel.mmsi)
        message.vessel_type = vessel.type
        message
      end
    end
  end
end