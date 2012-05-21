module Service
  class BaseService
    attr_writer :request_service
    
    def start(endpoint)
    end

    def stop
    end
    
    def request_service(handler)
      @request_service ||= RequestService.new(handler)
    end
  end
end