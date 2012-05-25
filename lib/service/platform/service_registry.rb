require 'ffi-rzmq'
require_relative 'base_service'
require_relative 'reply_service'
require_relative '../vessel_proxy'
require_relative '../transmitter_proxy'

module Service
  module Platform
    class ServiceRegistry < BaseService
      def initialize(registry=nil)
        @reply_service = ReplyService.new(method(:process_request))
        @endpoints = {}
      end
    
      def start(endpoint)
        @reply_service.start(endpoint)
        register_self('ais/registry', endpoint)
      end
      
      def wait
        @reply_service.wait
      end
      
      def stop
        @reply_service.stop
      end

      def register_self(name, endpoint)
        # Not required to register self
      end
    
      def lookup(name)
        if @endpoints.has_key?(name)
          @endpoints[name]
        else
          nil
        end
      end    
      
      def register(name, endpoint)
        @endpoints[name] = endpoint
      end
      
      def unregister(name)
        @endpoints.delete(name) if @endpoints.has_key?(name)
      end
      
      def process_request(data)
        type, *args = data.split(' ')
        if type == 'LOOKUP'
          lookup(args[0])   
        elsif type == 'REGISTER'
          register(args[0], args[1])
        elsif type == 'UNREGISTER'
          unregister(args[0])
        else
          raise "Unknown request type '#{type}'"          
        end
      end
    end
  end
end