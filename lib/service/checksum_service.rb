require_relative 'platform/base_service'
require_relative 'platform/reply_service'
require_relative '../util'
require_relative '../domain/ais/checksums'

module Service
  class ChecksumService < Platform::BaseService
    def initialize(registry)
      super(registry)
      @log = Util::get_log('checksum')
      @reply_service = Platform::ReplyService.new(method(:process_request), @log)
    end
    
    def start(endpoint)
      @log.debug("Starting service")
      super(endpoint)
      
      @reply_service.start(endpoint)
      
      register_self('ais/checksum', endpoint)
      @log.info("Service started")
    end
    
    def wait
      @reply_service.wait
    end

    def stop
      @reply_service.stop
      super
    end

    def process_request(request)
      valid = Domain::AIS::Checksums::verify(Marshal.load(request))
      Marshal.dump(valid)
    end
  end
end