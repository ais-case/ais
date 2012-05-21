module Service
  class TransmitterService < BaseService
    def initialize
      super
      @request_service = RequestService.new(method(:processRequest))
    end
    
    def start(endpoint)
      @request_service.start(endpoint)
    end
    
    def stop
      @request_service.stop
    end
    
    def processRequest(data)
      # TODO compile information in AIS message and deliver it
      # Nothing needs to be returned, empty response
      ""
    end  
  end
end