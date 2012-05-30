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
        int_class = Domain::AIS::Datatypes::Int
        uint_class = Domain::AIS::Datatypes::UInt 
        payload = ''
        
        # type
        payload << uint_class.new(@type).bit_string(6)
        
        # repeat 
        payload << '00'
        
        # mmsi
        payload << uint_class.new(@mmsi).bit_string(30)
        
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
        payload << uint_class.new(speed).bit_string(10)
        
        # accuracy
        payload << '0'
        
        # long
        payload << int_class.new(@lon * 600_000).bit_string(28)
        
        # lat
        payload << int_class.new(@lat * 600_000).bit_string(27)
        
        # course
        payload << '0' * 12 
        
        # heading
        heading = @heading ? @heading : 511
        payload << uint_class.new(heading).bit_string(9)

        # rest of message
        payload << '0' * 35
        
        payload
      end
    end
  end
end