require_relative 'platform/service_proxy'

module Service
  class TransmitterProxy < Platform::ServiceProxy
    def send_report(type, vessel)
      message = type << ' ' << Marshal.dump(vessel)
      @socket.send_string(message)      
    end
    
    def send_position_report_for(vessel)
      send_report('POSITION', vessel)
    end
    
    def send_static_report_for(vessel)
      send_report('STATIC', vessel)
    end
  end
end