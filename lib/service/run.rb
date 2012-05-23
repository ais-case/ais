#!/usr/bin/env ruby
if ARGV.length != 3
  raise 'Not enough arguments'
end

require_relative 'platform/service_registry_proxy'
require_relative ARGV[0]
service_class = ARGV[1]
endpoint = ARGV[2]

klass = Kernel
service_class.split('::').each do |name|
  klass = klass.const_get(name)   
end
  
r = klass.new Service::Platform::ServiceRegistryProxy.new
begin
  r.start(endpoint)
  r.wait
ensure
  r.stop
end
