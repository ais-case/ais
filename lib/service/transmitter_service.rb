module Service
  class TransmitterService < Platform::BaseService
    def initialize(registry)
      @reply_service = Platform::ReplyService.new(method(:process_request))
      @messages = Queue.new
      @client_threads = []
    end
    
    def start(endpoint)
      @reply_service.start(endpoint)
      
      @transmitter = Thread.new do
        socket = TCPServer.new(20000)
        begin
          clients = []
          cli_mutex = Mutex.new
          sender = Thread.new do
            loop do
              msg = @messages.pop
              cli_mutex.synchronize do
                clients.each do |client|
                  client.puts(msg)
                end
              end
            end
          end

          loop do
            client = socket.accept
            cli_mutex.synchronize do
              clients << client
            end
          end
        rescue
          puts $!
          raise
        ensure
          sender.kill
          socket.close
        end
      end

      sleep(3)
      
      Rails.configuration.ais_sources.each do |ais_source|
        @client_threads << Thread.new(ais_source) do |source|
          host, port = source
          socket = TCPSocket.new(host, port)
          begin
            loop do
              process_raw_message(socket.gets)
            end
          rescue
            puts $!
            raise
          ensure
            socket.close
          end
        end
      end
    end
    
    def stop
      @reply_service.stop
      @transmitter.kill if @transmitter
      @client_threads.each do |thread|
        thread.kill
      end
    end
        
    def checksum(msg)
      sum = 0 
      msg.each_byte do |c|
        sum^=c
      end
      return sum
    end
    
    def process_raw_message(data)
      return if data[0] == '#'
      i = data.index('!')
      return unless i
      @messages.push(data[i..-1])
    end
    
    def process_request(data)
      # Make sure Ruby knows about the unmarshalled classes
      Domain::Vessel.class
      Domain::LatLon.class
      
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