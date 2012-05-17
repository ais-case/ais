require 'ffi-rzmq'

class ServiceProxy
  def initialize(socket)
    @socket = socket
  end
end

class TransmitterProxy < ServiceProxy
  def send_position_report_for(vessel)
    message = Marshal.dump(vessel)
    @socket.send_string(message)
  end
end

class VesselServiceProxy < ServiceProxy
  def vessels
    @socket.send_string("")
    @socket.recv_string(message = "")
    return Marshal.load(message)
  end
end

class ServiceRegistry
  ENDPOINTS = { 
    'ais/transmitter' => { :endpoint => 'tcp://localhost:20010', :class => TransmitterProxy},
    'ais/vessels'     => { :endpoint => 'tcp://localhost:20011', :class => VesselServiceProxy}
  }

  def initialize(context=ZMQ::Context.new)
    @context = context
  end

  def bind(name)
    ep = ENDPOINTS[name][:endpoint]
    socket = @context.socket ZMQ::REQ

    rc = socket.connect ep

    if ZMQ::Util.resultcode_ok? rc
      proxy = ENDPOINTS[name][:class].new socket 
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