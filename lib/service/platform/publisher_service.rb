require 'ffi-rzmq'

module Service::Platform
  class PublisherService
    def initialize(log)
      @log = log
      @message_queue = Queue.new
    end
    
    def start(endpoint)
      done_queue = Queue.new
      
      @thread = Thread.new do
        begin
          ctx = ZMQ::Context.new
          socket = ctx.socket(ZMQ::PUB)
          socket.setsockopt(ZMQ::LINGER, 1000)
          rc = socket.bind(endpoint)
          raise "Couldn't listen to socket" unless ZMQ::Util.resultcode_ok?(rc)
          
          @log.debug("Publisher service thread started")
          done_queue.push(true)
          loop do
            data = @message_queue.pop
            @log.debug("Publishing message")
            socket.send_string(data)
          end
        rescue => e
          @log.fatal("Publisher service thread exception: #{e.message}")
          e.backtrace.each { |line| @log.fatal(line) }
          puts e.message
          done_queue.push(false)
          raise
        ensure
          socket.close
        end
      end
      
      begin
        timeout(2) do
          raise "Thread returned false" unless done_queue.pop
        end
      rescue
        raise RuntimeError, "Couldn't start service thread"
      end       
    end
    
    def wait
      @thread.join
    end
    
    def publish(data)
      @message_queue.push(data)
    end
    
    def stop
      @thread.kill if @thread
      @thread = nil
    end
  end
end