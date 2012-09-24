require 'json'
require 'net/http'

module Service::Platform
  class HttpSubscriberService
    def initialize(handler, log)
      @handler = handler
      @done_queue = Queue.new
      @log = log
    end
    
    def start(endpoint)
      @done_queue.clear
      
      @thread = Thread.new(@done_queue) do |queue|
        begin
          uri = URI(endpoint)

          Net::HTTP.start(uri.host, uri.port) do |http|
            http.read_timeout = 600
            request = Net::HTTP::Get.new uri.request_uri

            buffer = ''
            http.request request do |response|
              queue.push(true)
              response.read_body do |chunk|
                @log.debug("Received chunk: '#{chunk}'")
                buffer << chunk
        
                # Check if buffer holds a full JSON dictionary
                closing = buffer.index('}')

                # If it does, remove the JSON representation
                # from the buffer and parse it
                if not closing.nil?
                  dict = buffer.slice(0..closing) 
                  buffer = buffer.slice!(closing+1..buffer.length)

                  json = JSON::parse(dict)
                  json.each_value do |fields|
                    if fields[0] == 'message'
                      @log.debug("Received message")
                      @handler.call(fields[2])
                      @log.debug("Message handled")
                    end
                  end
                end
              end
            end
          end
        rescue => e
          @log.fatal("Http subscriber service thread exception: #{e.message}")
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
      rescue => e
          e.backtrace.each { |line| @log.fatal(line) }
          puts e.message
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
