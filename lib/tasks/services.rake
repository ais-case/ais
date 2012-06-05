namespace :services do
  task :start => :environment do
    sm = Service::Platform::ServiceManager.new
    begin
      sm.start
      puts "Started"
      puts "Waiting, stop services with CTRL-C"
      loop do
        sleep(3600)
      end
    ensure
      sm.stop
      puts "Stopped"
    end
  end
  
  task :starttest => :environment do
    sm = Service::Platform::ServiceManager.new
    begin
      sm.start
      puts "Started"
      registry = sm.registry_proxy

      @vessels = []
      
      vessel = Domain::Vessel.new(123456, Domain::Vessel::CLASS_A)
      vessel.type = Domain::VesselType.from_str("Tanker")
      vessel.position = Domain::LatLon.new(52.0, 4.3)
      vessel.heading = 45
      vessel.speed = 30.0
      @vessels << vessel
      

      vessel = Domain::Vessel.new(7890, Domain::Vessel::CLASS_B)
      vessel.type = Domain::VesselType.from_str("Passenger")
      vessel.position = Domain::LatLon.new(51.9, 4.2)
      vessel.heading = 90
      vessel.speed = 3.5
      @vessels << vessel

      @vessels.each do |v|
        registry.bind('ais/transmitter') do |service|
          service.send_position_report_for(v)
        end
        
        registry.bind('ais/transmitter') do |service|
          service.send_static_report_for(v)
        end
      end
            
      puts "Test messages sent"
      puts "Waiting, stop services with CTRL-C"
      loop do
        sleep(3600)
      end
    ensure
      sm.stop
      puts "Stopped"
    end    
  end
end