require_relative 'six_bit_encoding'
require_relative 'datatypes'
require_relative 'message1'
require_relative 'message5'
require_relative 'message18'
require_relative 'message19'
require_relative 'message24'
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
        message = nil
        mmsi = Datatypes::UInt.from_bit_string(decoded[8..37])
        if msg_type == 1 or msg_type == 2 or msg_type == 3
          if decoded.length >= 168
            message = Message1.new(mmsi)
            message.lat, message.lon = decode_latlon(decoded[89..115], decoded[61..88])
            message.speed = decode_speed(decoded[50..59])
            message.heading = decode_heading(decoded[128..136])            
          end
        elsif msg_type == 5
          if decoded.length >= 424
            message = Message5.new(mmsi)
            message.vessel_type = Domain::VesselType::new(Datatypes::UInt.from_bit_string(decoded[232..239]))
          end
        elsif msg_type == 18
          if decoded.length >= 168
            message = Message18.new(mmsi)
            message.lat, message.lon = decode_latlon(decoded[85..111], decoded[57..84])
            message.speed = decode_speed(decoded[46..55])
            message.heading = decode_heading(decoded[124..132])
          end
        elsif msg_type == 19
          if decoded.length >= 312
            message = Message19.new(mmsi)
            message.lat, message.lon = decode_latlon(decoded[85..111], decoded[57..84])
            message.speed = decode_speed(decoded[46..55])
            message.heading = decode_heading(decoded[124..132])
          end
        elsif msg_type == 24
          if decoded.length >= 168 and decoded[38..39] == '01'
            message = Message24.new(mmsi)
            message.vessel_type = Domain::VesselType::new(Datatypes::UInt.from_bit_string(decoded[40..47]))
          end
        else
          raise "Unknown message type #{msg_type}"
        end
        
        message
      end
      
      def self.decode_latlon(lat_bits, lon_bits)
        [lat_bits, lon_bits].map do |bits|
          val = Datatypes::Int.from_bit_string(bits)
          val.to_f / 600_000.0          
        end
      end
      
      def self.decode_speed(bits)
        speed = Datatypes::UInt.from_bit_string(bits)
        (speed == 1023) ? nil : speed.to_f / 10.0
      end
      
      def self.decode_heading(bits)
        heading = Datatypes::UInt.from_bit_string(bits)
        (heading == 511) ? nil : heading
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
        if vessel.vessel_class == Domain::Vessel::CLASS_B
          message = Message24.new(vessel.mmsi)
        else
          message = Message5.new(vessel.mmsi)
        end
        message.vessel_type = vessel.type
        message
      end
    end
  end
end