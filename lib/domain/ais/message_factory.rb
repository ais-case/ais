require_relative 'six_bit_encoding'
require_relative 'datatypes'
require_relative 'message1'
require_relative 'message5'
require_relative 'message18'
require_relative 'message19'
require_relative '../vessel'
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
  
            speed = Datatypes::UInt.from_bit_string(decoded[50..59]).value
            message.speed = (speed == 1023) ? nil : speed.to_f / 10.0
            
            heading = Datatypes::UInt.from_bit_string(decoded[128..136]).value
            message.heading = (heading == 511) ? nil : heading
            
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
        if vessel.vessel_class == Domain::Vessel::CLASS_B
          message = Message18.new(vessel.mmsi)
        else
          message = Message1.new(vessel.mmsi)
        end
        message.lon = vessel.position.lon
        message.lat = vessel.position.lat
        message.speed = vessel.speed
        message.heading = vessel.heading
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