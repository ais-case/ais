require 'ffi-rzmq'

module Service::Platform
  class ServiceRegistry
    ENDPOINTS = { 
      'ais/transmitter' => { :endpoint => 'tcp://localhost:21000', :class => Service::TransmitterProxy},
      'ais/vessels'     => { :endpoint => 'tcp://localhost:21001', :class => Service::VesselServiceProxy},
      'ais/message'     => { :endpoint => 'tcp://localhost:21002', :class => nil}
    }
  
    def initialize(context=ZMQ::Context.new)
      @context = context
    end
  
    def lookup(name)
      ENDPOINTS[name][:endpoint]
    end
  
    def bind(name)
      endpoint = lookup(name)
      socket = @context.socket(ZMQ::REQ)
      rc = socket.connect(endpoint)
      if ZMQ::Util.resultcode_ok?(rc)
        proxy = ENDPOINTS[name][:class].new(socket) 
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