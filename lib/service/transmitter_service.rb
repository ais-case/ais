require 'socket'
require 'thread'
require_relative '../util'
require_relative '../domain/vessel'
require_relative '../domain/vessel_type'
require_relative '../domain/lat_lon'
require_relative '../domain/ais/checksums'
require_relative '../domain/ais/datatypes'
require_relative '../domain/ais/six_bit_encoding'
require_relative '../domain/ais/message_factory'
require_relative 'platform/base_service'
require_relative 'platform/reply_service'

module Service
  class TransmitterService < Platform::BaseService
    def initialize(registry)
      super(registry)
      @log = Util::get_log('transmitter')
      @reply_service = Platform::ReplyService.new(method(:process_request), @log)
      @messages = Queue.new
      @client_threads = []
    end
    
    def start(endpoint)
      @log.debug("Starting service")
      @reply_service.start(endpoint)
      
      ready_queue = Queue.new
      ready_queue.clear
      @transmitter = Thread.new do
        begin
          socket = TCPServer.new(20000)
          clients = []
          cli_mutex = Mutex.new
          sender = Thread.new do
            begin
              ready_queue.push true
              loop do
                msg = @messages.pop
                @log.debug("Broadcasting message #{msg} to #{clients.length} client(s)")
                cli_mutex.synchronize do
                  clients.each do |client|
                    client.puts(msg)
                  end
                end
              end
            rescue
              @log.fatal("Sender thread raised exception: #{$!}")            
            end
          end

          loop do
            client = socket.accept
            @log.debug("Accepted client")
            cli_mutex.synchronize do
              clients << client
            end
          end
        rescue
          @log.fatal("Transmitter thread raised exception: #{$!}")            
          puts $!
          raise
        ensure
          sender.kill
          clients.each do |client|
            client.close
          end            
          socket.close
        end
      end

      timeout(3) do
        ready_queue.pop
      end
      
      if ENV.has_key?('RAILS_ENV') and ENV['RAILS_ENV'] == 'test'
        ais_sources = [] 
      else
        ais_sources = [['82.210.120.176', 20000]] 
      end
      
      ais_sources.each do |ais_source|
        @log.debug("Added AIS source #{ais_sources[0]}:#{ais_sources[1]}")
        @client_threads << Thread.new(ais_source) do |source|
          begin
            host, port = source
            socket = TCPSocket.new(host, port)
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
      register_self('ais/transmitter', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @reply_service.wait
      @transmitter.wait
    end
    
    def stop
      @reply_service.stop
      @transmitter.kill if @transmitter
      @client_threads.each do |thread|
        thread.kill
      end
      @transmitter = nil
      @client_threads = []
      @log.info("Service stopped")
    end
        
    def process_raw_message(data)
      return if data[0] == '#'
      i = data.index('!')
      return unless i
      broadcast_message(data[i..-1])
    end
    
    def broadcast_message(message)
      @messages.push(message)      
    end
    
    def process_request(data)
      # Make sure Ruby knows about the unmarshalled classes
      Domain::Vessel.class
      Domain::LatLon.class
      
      type_end = data.index(' ')
      type = data[0..(type_end - 1)]
      vessel = Marshal.load(data[(type_end + 1)..-1])
      
      fragments = []
      message_factory = Domain::AIS::MessageFactory.new
      if type == 'POSITION'
        message = message_factory.create_position_report(vessel)
      elsif type == 'STATIC'
        message = message_factory.create_static_info(vessel)
      else
        @log.error("Invalid request type: #{type}")
        return ''        
      end
      
      # Create the fragments
      encoded = Domain::AIS::SixBitEncoding.encode(message.payload)

      chunk_no = 1
      chunks = encoded.scan(/.{1,56}/)
      chunks.each do |chunk|
        fragment = "!AIVDM,#{chunks.length},#{chunk_no},,A,#{chunk},0"
        packet = Domain::AIS::Checksums::add(fragment) << "\n"
        broadcast_message(packet)
        chunk_no += 1  
      end 
      
      # Empty response
      ''
    end  
  end
end