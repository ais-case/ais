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
end