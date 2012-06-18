
module Service::Platform
  class ServiceManager
    attr_writer :bindings
    
    BINDINGS = [{:endpoint => 'tcp://*:0', :service => 'Service::Platform::ServiceRegistry', :file => 'platform/service_registry'},
                {:endpoint => 'tcp://*:0', :service => 'Service::PayloadDecoderService', :file => 'payload_decoder_service'},
                {:endpoint => 'tcp://*:0', :service => 'Service::PayloadEncoderService', :file => 'payload_encoder_service'},
                {:endpoint => 'tcp://*:0', :service => 'Service::TransmitterService', :file => 'transmitter_service'},
                {:endpoint => 'tcp://*:0', :service => 'Service::ReceiverService', :file => 'receiver_service'},
                {:endpoint => 'tcp://*:0', :service => 'Service::CombinerService', :file => 'combiner_service'},
                {:endpoint => 'tcp://*:0', :service => 'Service::MessageService', :file => 'message_service'},
                {:endpoint => 'tcp://*:0', :service => 'Service::ComplianceService', :file => 'compliance_service'},
                {:endpoint => 'tcp://*:0', :service => 'Service::VesselService', :file => 'vessel_service'}]
    
    def initialize
      @services = []
      @registry_endpoint = nil
    end
    
    def get_bindings
      @bindings ||= BINDINGS
      @bindings[0][:endpoint] = get_registry_endpoint.gsub(/localhost/, '*')
      @bindings
    end
    
    def get_registry_endpoint
      if @registry_endpoint
        @registry_endpoint
      else
        if defined?(Rails)
          @registry_endpoint = Rails.configuration.registry_endpoint
        else          
          port = 21000 + rand(1..999)
          @registry_endpoint = "tcp://localhost:#{port}"
        end
      end
    end
    
    def registry_proxy
      ServiceRegistryProxy.new get_registry_endpoint
    end
    
    def start
      runner = File.dirname(__FILE__) << '/../run.rb'
      
      get_bindings.each do |binding|
        args = Marshal.dump([binding[:file], binding[:service], binding[:endpoint], get_registry_endpoint])
        pipe = IO.popen([runner, binding[:service]], 'r+')
        pipe.write(args + "\n")
        output = pipe.readline
        if output != "STARTED\n"
          raise "Couldn't start process for service #{binding[:service]}: #{output}"
        end
        @services << pipe
      end
      sleep(0.1)
    end
    
    def stop
      @services.each do |pipe|    
        Process.kill('TERM', pipe.pid)
      end
      @services.clear
    end
  end
end