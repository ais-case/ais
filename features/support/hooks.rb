require 'capybara/rails'

Before do
  Capybara.current_driver = Capybara.javascript_driver
  @manager = Service::Platform::ServiceManager.new
  @manager.start
  @registry = @manager.registry_proxy
  @failed_scenarios = 0
end

After do |scenario|
  @manager.stop
  
  if scenario.failed?
    @failed_scenarios += 1
    #name = scenario.to_sexp[3]
    name = @failed_scenarios.to_s
    logbase = Rails.root.join('log', name.gsub(' ', '_'))
    FileUtils.makedirs(logbase) 
    Dir.glob(Rails.root.join('log', 'log-*.log')).each do |log|
      FileUtils.copy(log, File.join(logbase, File.basename(log)))
    end
  end
  
  FileUtils.rm(Dir.glob(Rails.root.join('log', 'log-*.log')))
end