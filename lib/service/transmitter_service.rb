module Service
  class TransmitterService < BaseService
    def initialize(registry)

      @reply_service = ReplyService.new(method(:processRequest))
    end
    
    def start(endpoint)
      @reply_service.start(endpoint)
    end
    
    def stop
      @reply_service.stop
    end
    
    def processRequest(data)
      # TODO compile information in AIS message and deliver it
      # Nothing needs to be returned, empty response
      ""
    end  
  end
end