require 'thread'
require_relative 'platform/service_registry_proxy'

module Service
  class VesselProxySingleton
    private_class_method :new
    @@mutex = Mutex.new
    @@instance = nil
      
    def initialize
      @request_queue = SizedQueue.new(1)
      @reply_queue = SizedQueue.new(1)
      
      @thread = Thread.new(@request_queue, @reply_queue) do |request_queue, reply_queue|
        begin 
          registry = Service::Platform::ServiceRegistryProxy.new(Rails.configuration.registry_endpoint)
          service = registry.bind('ais/vessel')
          
          while true
            request, args = request_queue.pop
            if request == 'vessels'
              if args.length == 2
                reply = service.vessels(args[0], args[1])
              else
                reply = service.vessels
              end
            elsif request == 'info'
              reply = service.info(args[0])
            end
            reply_queue.push(reply)
          end
        rescue => e
          e.backtrace.each { |line| Rails.logger.fatal(line) }
        ensure
          service.release
          registry.release
        end
      end
    end
    
    def self.instance
      @@mutex.synchronize do
        @@instance = new unless @@instance
        @@instance
      end
    end
  
    def vessels(*args)
      @request_queue.push(['vessels', args])
      @reply_queue.pop   
    end
  
    def info(mmsi)
      @request_queue.push(['info', mmsi])
      @reply_queue.pop   
    end
    
    def destroy
      @@mutex.synchronize do
        if @@instance
          Thread.kill(@thread)
          @@instance = nil
        end
      end
    end
  end
end