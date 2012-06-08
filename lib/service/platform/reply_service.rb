require 'ffi-rzmq'
require 'timeout'

module Service
  module Platform
    class ReplyService
      def initialize(handler, log)
        @handler = handler
        @thread = nil
        @done_queue = Queue.new
        @log = log
      end
      
      def start(endpoint)
        @done_queue.clear
        
        @thread = Thread.new(@done_queue) do |queue|
          context = ZMQ::Context.new
          socket = context.socket(ZMQ::REP)
          begin
            socket.bind(endpoint)
            queue.push(true)
            @log.debug("Reply service thread started")
            loop do 
              data = ''
              socket.recv_string(data)
              @log.debug("Reply service received request")
              socket.send_string(@handler.call(data))
              @log.debug("Reply service replied to request")
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
          @log.fatal("Reply service thread not started")
          raise RuntimeError, "Couldn't start service listener"
        end
        @log.debug("Reply service started")
      end
      
      def wait
        @thread.join
      end
      
      def stop
        @thread.kill if @thread
        @thread = nil
        @log.debug("Reply service stopped")
      end
    end  
  end
end