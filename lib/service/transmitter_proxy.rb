require_relative 'platform/service_proxy'

module Service
  class TransmitterProxy < Platform::ServiceProxy
    def send_report(type, vessel, timestamp)
      args = [vessel, timestamp ? timestamp : Time.now]
      message = type << ' ' << Marshal.dump(args)
      @socket.send_string(message)
    end
    
    def send_position_report_for(vessel, timestamp=nil)
      send_report('POSITION', vessel, timestamp)
    end
    
    def send_static_report_for(vessel, timestamp=nil)
      send_report('STATIC', vessel, timestamp)
    end
  end
end