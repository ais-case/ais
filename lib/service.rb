require 'ffi-rzmq'

class TransmitterProxy
    def initialize(socket)
        @socket = socket
    end
    
    def send_position_report_for(vessel)
        message = Marshal.dump(vessel)
        @socket.send(message)
    end
end

class Service
    ENDPOINTS = { :transmitter => 'tcp://localhost:20010'}

    def initialize()
        @context = ZMQ::Context.new
    end

    def bind(name)
        ep = ENDPOINTS[:transmitter]
        socket = @context.socket ZMQ::REQ
        rc = socket.connect ep 
        if ZMQ::Util.resultcode_ok? rc
            raise RuntimeError, "Couldn't connect to #{ep}"
        end
        return TransmitterProxy.new socket
    end
end