namespace :services do
  task :start => :environment do
    sm = Service::Platform::ServiceManager.new
    begin
      sm.start
      puts "Started"
      loop do
        sleep(3600)
      end
    ensure
      sm.stop
      puts "Stopped"
    end
  end
  
  task :test => :environment do
    v = Domain::Vessel.new(9999, Domain::Vessel::CLASS_A)
    v.name="Whoop"
    v.position=Domain::LatLon.new(52,4)
    Service::Platform::ServiceRegistry.new.bind('ais/transmitter') do |s|
      s.send_position_report_for(v)
    end
  end
end