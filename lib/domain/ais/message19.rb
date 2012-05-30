require_relative '../vessel'
require_relative 'message18'

module Domain
  module AIS
    class Message19 < Message18
      
      def initialize(mmsi)
        super(mmsi)
        @type = 19
      end
      
      def payload
        payload = super

        # rest of message
        payload << '0' * 144
        
        payload
      end
    end
  end
end