require_relative 'reply_service'

module Service
  module Platform
    class BaseService
      attr_writer :reply_service
      
      def initialize(registry)
        @registry = registry
      end
      
      def start(endpoint)
      end
  
      def wait
        raise "Wait not implemented"
      end
  
      def stop
      end
      
      def register_self(name, endpoint)
        @registry.register(name, endpoint.gsub(/\*/, 'localhost'))
      end
      
      def reply_service(handler)
        @reply_service ||= ReplyService.new(handler)
      end
    end
  end
end