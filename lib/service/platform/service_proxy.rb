module Service
  module Platform
    class ServiceProxy
      def initialize(socket)
        @socket = socket
      end
      
      def release
        @socket.close
      end
    end
  end
end