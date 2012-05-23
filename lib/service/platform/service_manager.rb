module Service::Platform
  class ServiceManager
    attr_writer :bindings
    
    BINDINGS = [{:endpoint => 'tcp://*:21000', :service => Service::TransmitterService},
                {:endpoint => 'tcp://*:21002', :service => Service::MessageService},
                {:endpoint => 'tcp://*:21001', :service => Service::VesselService}]
    
    def initialize
      @services = []
    end
    
    def get_bindings
      @bindings ||= BINDINGS 
    end
    
    def get_registry
      @registry ||= ServiceRegistryProxy.new
    end
    
    def start
      get_bindings.each do |binding|
        service = binding[:service].new(get_registry)
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