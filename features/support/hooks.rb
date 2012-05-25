require 'capybara/rails'

Before do
  Capybara.current_driver = Capybara.javascript_driver
  @manager = Service::Platform::ServiceManager.new
  @manager.start
  @registry = @manager.registry_proxy
end

After do |scenario|
  @manager.stop
end