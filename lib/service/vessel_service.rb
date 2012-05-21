require 'ffi-rzmq'

module Service
  class VesselService < BaseService
    def initialize
      @vessels = []
      @vessels_mutex = Mutex.new
      @request_service = RequestService.new(method(:processMessage))
    end
    
    def start(endpoint)
      super(endpoint)
      
      @request_service.start(endpoint)
      
      @subscriber_thread = Thread.new do
        ctx = ZMQ::Context.new
        socket = ctx.socket(ZMQ::SUB)
        socket.setsockopt(ZMQ::SUBSCRIBE, "1")
        begin
          rc = socket.connect('tcp://localhost:24000')
          raise "Couldn't listen to socket" unless ZMQ::Util.resultcode_ok?(rc)
          
          loop do
            data = ''
            socket.recv_string(data)
            fields = data.split(' ')
            processMessage(fields[1])
          end
       rescue
          puts $!
          raise
        ensure
          socket.close
        end
      end
      
      # Extra time needed for this socket to connect
      sleep(2)
    end

    def stop
      @request_service.stop
      @subscriber_thread.kill if @subscriber_thread
      super
    end

    def processMessage(payload)
      message = Domain::AIS::MessageFactory.fromPayload(payload)
      vessel = Domain::Vessel.new(message.mmsi, message.vessel_class)
      vessel.position = Domain::LatLon.new(message.lat, message.lon)
      @vessels << vessel
    end
    
     def receiveVessel(vessel)
      @vessels_mutex.synchronize do
        @vessels << vessel
      end
    end
    
    def processRequest(request)
      @vessels_mutex.synchronize do
        Marshal.dump(@vessels)
      end
    end
  end
end