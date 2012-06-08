require_relative 'platform/service_proxy'

module Service
  class ChecksumProxy < Platform::ServiceProxy
    def verify(message)
      @socket.send_string(Marshal.dump(message))
      @socket.recv_string(response = "")
      Marshal.load(response)
    end
  end
end