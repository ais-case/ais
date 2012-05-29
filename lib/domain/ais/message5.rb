require_relative '../vessel'

module Domain
  module AIS
    class Message5
      attr_reader :mmsi, :type
      attr_accessor :vessel_type
      
      def initialize(mmsi)
        @mmsi = mmsi
        @type = 5
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
        
        # version, imo, call sign
        payload << '0' * 74
        
        # name
        payload << '0' * 120
        
        # type
        if @vessel_type
          code = @vessel_type.code
        else
          code = 0  
        end
         
        payload << int_class.new(code).bit_string(8)
        
        # rest of message
        payload << '0' * 184
        
        payload
      end
    end
  end
end