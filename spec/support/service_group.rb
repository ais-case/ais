shared_examples_for "a service" do
  it "can be started and stopped" do
    service = described_class.new
    service.start 'tcp://*:21000'
    service.stop
  end
  
  it "accepts requests on a socket" do
    mock_class = Class.new(described_class) do
      def processRequest(data)
        data
      end
    end
    service = mock_class.new
    service.start 'tcp://*:22000'
     
    ctx = ZMQ::Context.new
    sock = ctx.socket ZMQ::REQ
    rc = sock.connect 'tcp://localhost:22000'
    ZMQ::Util.resultcode_ok?(rc).should be_true
    begin
      sock.send_string(Marshal.dump("Test"))
      response = ''
      sock.recv_string(response)
      response.should eq(Marshal.dump("Test"))
    ensure
      sock.close
      service.stop
    end
  end    
end