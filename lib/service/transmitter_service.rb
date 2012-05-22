module Service
  class TransmitterService < BaseService
    def initialize(registry)
      @reply_service = ReplyService.new(method(:process_request))
      @messages = Queue.new
    end
    
    def start(endpoint)
      @reply_service.start(endpoint)
      
      @transmitter = Thread.new do
        socket = TCPServer.new(20000)
        begin
          client = socket.accept
          loop do
            client.puts(@messages.pop)
          end
        ensure 
          socket.close
        end
      end
      
      sleep(2)
    end
    
    def stop
      @reply_service.stop
      @transmitter.kill if @transmitter
    end
        
    def checksum(msg)
      sum = 0 
      msg.each_byte do |c|
        sum^=c
      end
      return sum
    end
    
    def process_request(data)
      vessel = Marshal.load(data)
      int_class = Domain::AIS::Datatypes::Int 
      payload = ''
      payload << int_class.new(1).bit_string(6)
      payload << '00'
      payload << int_class.new(vessel.mmsi).bit_string(30)
      payload << '0' * 23
      payload << int_class.new(vessel.position.lon * 600_000).bit_string(28)
      payload << int_class.new(vessel.position.lat * 600_000).bit_string(27)
      payload << '0' * 51
      
      message = "AIVDM,1,1,,A,#{Domain::AIS::SixBitEncoding.encode(payload)},0*"
      message << checksum(message).to_s(16)
      message = "!" << message
      
      @messages.push(message)
      
      ""
    end  
  end
end