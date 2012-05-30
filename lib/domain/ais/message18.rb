require_relative '../vessel'

module Domain
  module AIS
    class Message18
      attr_reader :mmsi, :vessel_class, :type
      attr_accessor :lat, :lon, :speed, :heading
      
      def initialize(mmsi)
        @mmsi = mmsi
        @vessel_class = Domain::Vessel::CLASS_B
        @type = 18
      end
      
      def payload
        int = Domain::AIS::Datatypes::Int
        uint = Domain::AIS::Datatypes::UInt 
        payload = ''
        
        # type
        payload << uint.bit_string(@type, 6)

        # repeat 
        payload << '00'
        
        # mmsi
        payload << uint.bit_string(@mmsi, 30)
        
        # reserved
        payload << '0' * 8
        
        # speed
        if not @speed
          speed = 1023
        elsif @speed > 102.2
          speed = 1022
        else
          speed = (@speed * 10).to_i
        end
        payload << uint.bit_string(speed, 10)
        
        # accuracy
        payload << '0'
        
        # long
        payload << int.bit_string(@lon * 600_000, 28)
        
        # lat
        payload << int.bit_string(@lat * 600_000, 27)
        
        # course
        payload << '0' * 12 
        
        # heading
        heading = @heading ? @heading : 511
        payload << uint.bit_string(heading, 9)

        # rest of message
        payload << '0' * 35
        
        payload
      end
    end
  end
end