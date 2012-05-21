require 'spec_helper'
require 'ffi-rzmq'

module Service
  describe MessageService do
    #it_behaves_like "a service"
    
    it "listens for raw AIS data" do
      server = Thread.new do
        socket = TCPServer.new(20000)
        begin
          client = socket.accept
          client.puts("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00")
        ensure 
          socket.close
        end
      end
      
      sleep(1)

      service = MessageService.new
      service.should_receive(:processRawMessage).with("!AIVDM,1,1,,B,13OF<80vh2wgiJJNes7EMGrD0<0e,0*00\n")        
      service.start('tcp://localhost:25000')

      # Give service time to receive and process message
      sleep(0.1)
        
      service.stop
    end
  end
end