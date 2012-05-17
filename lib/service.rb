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

class VesselServiceProxy
  def initialize(socket)
    @socket = socket
  end
  
  def vessels
    @socket.send_string("")
    @socket.recv_string(message = "")
    return Marshal.load(message)
  end
end

class Service
  ENDPOINTS = { 
    'ais/transmitter' => { :endpoint => 'tcp://localhost:20010', :class => TransmitterProxy},
    'ais/vessels'     => { :endpoint => 'tcp://localhost:20011', :class => VesselServiceProxy}
  }

  def initialize(context=ZMQ::Context.new)
    @context = context
    @sockets = []
  end

  def bind(name)
    ep = ENDPOINTS[name][:endpoint]
    socket = @context.socket ZMQ::REQ
    @sockets << socket

    rc = socket.connect ep

    if ZMQ::Util.resultcode_ok? rc
      return ENDPOINTS[name][:class].new socket
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