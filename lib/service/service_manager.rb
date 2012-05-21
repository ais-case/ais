module Service
  class ServiceManager
    attr_writer :bindings
    
    BINDINGS = [{:endpoint => 'tcp://*:21000', :service => TransmitterService},
                {:endpoint => 'tcp://*:21001', :service => VesselService},
                {:endpoint => 'tcp://*:21002', :service => MessageService}]
    
    def initialize
      @services = []
    end
    
    def get_bindings
      @bindings ||= BINDINGS 
    end
    
    def start
      get_bindings.each do |binding|
        service = binding[:service].new
        service.start(binding[:endpoint])
        @services << service
      end
    end
    
    def stop
      @services.each do |service|    
        service.stop
      end
      @services.clear
    end
  end
end