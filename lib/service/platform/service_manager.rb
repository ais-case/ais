
module Service::Platform
  class ServiceManager
    attr_writer :bindings
    
    BINDINGS = [{:endpoint => 'tcp://*:21000', :service => 'Service::TransmitterService', :file => 'transmitter_service'},
                {:endpoint => 'tcp://*:21002', :service => 'Service::MessageService', :file => 'message_service'},
                {:endpoint => 'tcp://*:21001', :service => 'Service::VesselService', :file => 'vessel_service'}]
    
    def initialize
      @services = []
    end
    
    def get_bindings
      @bindings ||= BINDINGS 
    end
    
    def start
      runner = File.dirname(__FILE__) << '/../run.rb'
      get_bindings.each do |binding|
        @services << Process.spawn(runner, binding[:file], binding[:service], binding[:endpoint])
        sleep(0.5)
      end
    end
    
    def stop
      @services.each do |pid|    
        Process.kill('KILL', pid)
      end
      @services.clear
    end
  end
end