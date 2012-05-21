require 'ffi-rzmq'

module Service
  class ServiceRegistry
    ENDPOINTS = { 
      'ais/transmitter' => { :endpoint => 'tcp://localhost:21000', :class => TransmitterProxy},
      'ais/vessels'     => { :endpoint => 'tcp://localhost:21001', :class => VesselServiceProxy}
    }
  
    def initialize(context=ZMQ::Context.new)
      @context = context
    end
  
    def bind(name)
      endpoint = ENDPOINTS[name][:endpoint]
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