module Service
  class VesselServiceProxy < ServiceProxy
    def vessels
      @socket.send_string("")
      @socket.recv_string(message = "")
      return Marshal.load(message)
    end
  end
end
