require 'ffi-rzmq'

module Service::Platform
  class SubscriberService
    def initialize(handler, filters, log)
      @handler = handler
      @filters = filters
      @done_queue = Queue.new
      @log = log
    end
    
    def start(endpoint)
      @done_queue.clear
      
      @thread = Thread.new(@done_queue) do |queue|
        begin
          ctx = ZMQ::Context.new
          socket = ctx.socket(ZMQ::SUB)
          socket.setsockopt(ZMQ::LINGER, 1000)
          @filters.each do |filter|
            socket.setsockopt(ZMQ::SUBSCRIBE, filter)
          end
          rc = socket.connect(endpoint)
          raise "Couldn't listen to socket #{endpoint}" unless ZMQ::Util.resultcode_ok?(rc)
          
          # For some reason the socket needs some time before it's functional
          sleep(0.1)
          @log.debug("Subscribed service thread started")
          queue.push(true)
          loop do
            data = ''
            socket.recv_string(data)
            @log.debug("Received message")
            @handler.call(data)
            @log.debug("Message handled")
          end
        rescue => e
          @log.fatal("Subscriber service thread exception: #{e.message}")
          e.backtrace.each { |line| @log.fatal(line) }
          puts e.message
          queue.push(false)
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
    
    def wait
      @thread.join
    end
    
    def stop
      @thread.kill if @thread
      @thread = nil
    end
  end
end