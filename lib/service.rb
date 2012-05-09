require 'ffi-rzmq'

class TransmitterProxy
    def initialize(socket)
        @socket = socket
    end
    
    def send_position_report_for(vessel)
        message = Marshal.dump(vessel)
        @socket.send_string(message)
    end
end

class Service
    ENDPOINTS = { :transmitter => 'tcp://localhost:20010'}

    def initialize(context=ZMQ::Context.new)
        @context = context
        @sockets = []
    end
    
    def bind(name)
        ep = ENDPOINTS[:transmitter]
        socket = @context.socket ZMQ::REQ
        @sockets << socket
        
        rc = socket.connect ep

        if ZMQ::Util.resultcode_ok? rc
            return TransmitterProxy.new socket
        else
            raise RuntimeError, "Couldn't connect to #{ep}"
        end
    end
    
    def terminate
        @sockets.each do |socket|
            socket.close
        end
    end
end