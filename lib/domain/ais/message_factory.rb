require_relative 'six_bit_encoding'
require_relative 'datatypes'
require_relative 'message1'
require_relative 'message5'
require_relative '../vessel_type'

module Domain
  module AIS
    class MessageFactory
      def self.fromPayload(payload)
        
        # Note that checks for length use >, because the messages might be 
        # longer due to padding of the payload. This padding won't influence
        # values, since only the least significant bits at the end of the 
        # message are padded.
        
        decoded = SixBitEncoding.decode(payload)
        msg_type = decoded[0..5].to_i(2)
        if msg_type == 1 or msg_type == 2 or msg_type == 3
          if decoded.length >= 168
            message = Message1.new(Datatypes::UInt.from_bit_string(decoded[8..37]).value)
            lon = Datatypes::Int.from_bit_string(decoded[61..88])
            lat = Datatypes::Int.from_bit_string(decoded[89..115])
            message.lon = lon.value / 600000.0
            message.lat = lat.value / 600000.0
            message
          else
            nil
          end
        elsif msg_type == 5
          if decoded.length >= 424
            message = Message5.new(Datatypes::UInt.from_bit_string(decoded[8..37]).value)
            message.vessel_type = Domain::VesselType::new(Datatypes::UInt.from_bit_string(decoded[232..239]).value)
            message
          else
            nil
          end
        else
          raise "Unknown message type #{msg_type}"
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