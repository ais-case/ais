require_relative '../vessel'

module Domain
  module AIS
    class Message
      attr_reader :mmsi, :vessel_class, :type
      attr_accessor :lat, :lon
      
      def initialize(mmsi)
        @mmsi = mmsi
        @vessel_class = Domain::Vessel::CLASS_A
        @type = 1
      end
      
      def payload
        int_class = Domain::AIS::Datatypes::Int 
        payload = ''
        
        # type
        payload << int_class.new(@type).bit_string(6)
        
        # repeat 
        payload << '00'
        
        # mmsi
        payload << int_class.new(@mmsi).bit_string(30)
        
        # nav status, rot, sog, accuracy
        payload << '0' * 23
        
        # long
        payload << int_class.new(@lon * 600_000).bit_string(28)
        
        # lat
        payload << int_class.new(@lat * 600_000).bit_string(27)
        
        # rest of message
        payload << '0' * 53
        
        payload
      end
    end
  end
end