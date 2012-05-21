require 'ffi-rzmq'

module Service
  class SubscriberService
    def initialize(handler, filters)
      @handler = handler
      @filters = filters
    end
    
    def start(endpoint)
      @thread = Thread.new do
        ctx = ZMQ::Context.new
        socket = ctx.socket(ZMQ::SUB)
        begin
          @filters.each do |filter|
            socket.setsockopt(ZMQ::SUBSCRIBE, filter)
          end
          rc = socket.connect(endpoint)
          raise "Couldn't listen to socket" unless ZMQ::Util.resultcode_ok?(rc)
          
          loop do
            data = ''
            socket.recv_string(data)
            @handler.call(data)
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
      @thread.kill if @thread
    end
  end
end