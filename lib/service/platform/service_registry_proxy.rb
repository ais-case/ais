require 'ffi-rzmq'
require 'timeout'
require_relative 'base_service'
require_relative '../vessel_proxy'
require_relative '../transmitter_proxy'

module Service
  module Platform
    class ServiceRegistryProxy
      attr_writer :context
      
      PROXIES = { 
        'ais/transmitter' => Service::TransmitterProxy,
        'ais/vessel'      => Service::VesselProxy,
        'ais/message'     => nil
      }
    
      def initialize(endpoint)
        @endpoint = endpoint
        @context = ZMQ::Context.new
      end
    
      def request(req)
        socket = @context.socket(ZMQ::REQ)
        rc = socket.connect(@endpoint)
        if ZMQ::Util.resultcode_ok?(rc)
          begin
            socket.send_string(req)
            socket.recv_string(res = '')
            res = nil if res == ''
          ensure
            socket.close
          end
        else
          raise RuntimeError, "Couldn't connect to #{ep}"
        end
        res
      end
 
      def register(name, endpoint)
        request("REGISTER #{name} #{endpoint}")
      end
      
      def lookup(name, seconds = 5)
          timeout(seconds) do
          loop do
            endpoint = request("LOOKUP #{name}")
            return endpoint unless endpoint == nil
            sleep(0.1)
          end
        end
      end
    
      def bind(name)
        endpoint = lookup(name)
        socket = @context.socket(ZMQ::REQ)
        rc = socket.connect(endpoint)
        if ZMQ::Util.resultcode_ok?(rc)
          proxy = PROXIES[name].new(socket) 
          begin
            yield proxy
          ensure
            socket.close
          end
        else
          raise RuntimeError, "Couldn't connect to #{ep}"
        end
      end
    end
  end
end