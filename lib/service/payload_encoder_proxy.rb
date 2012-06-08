require_relative 'platform/service_proxy'

module Service
  class PayloadEncoderProxy < Platform::ServiceProxy
    def encode(payload)
      @socket.send_string(Marshal.dump(payload))
      @socket.recv_string(response = "")
      Marshal.load(response)
    end
  end
end