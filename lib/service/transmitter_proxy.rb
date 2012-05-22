module Service
  class TransmitterProxy < Platform::ServiceProxy
    def send_position_report_for(vessel)
      message = Marshal.dump(vessel)
      @socket.send_string(message)
    end
  end
end