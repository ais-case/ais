require 'ffi-rzmq'

module Service
  class SubscriberService
    def initialize(handler, filters)
      @handler = handler
      @filters = filters
      @done_queue = Queue.new
    end
    
    def start(endpoint)
      @done_queue.clear
      
      @thread = Thread.new(@done_queue) do |queue|
        ctx = ZMQ::Context.new
        socket = ctx.socket(ZMQ::SUB)
        begin
          @filters.each do |filter|
            socket.setsockopt(ZMQ::SUBSCRIBE, filter)
          end
          rc = socket.connect(endpoint)
          raise "Couldn't listen to socket" unless ZMQ::Util.resultcode_ok?(rc)
          
          # For some reason the socket needs some time before it's functional
          sleep(0.1)
          
          queue.push(true)
          loop do
            data = ''
            socket.recv_string(data)
            @handler.call(data)
          end
        rescue
          queue.push(false)
          puts $!
          raise
        ensure
          socket.close
        end
      end
      
      begin
        timeout(2) do
          raise "Thread returned false" unless @done_queue.pop
        end
      rescue
        raise RuntimeError, "Couldn't start service listener"
      end       
    end
    
    def stop
      @thread.kill if @thread
    end
  end
end