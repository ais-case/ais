#!/usr/bin/env ruby
if ARGV.length != 4
  raise 'Invalid number of arguments'
end

require_relative 'platform/service_registry_proxy'
require_relative ARGV[0]
service_class = ARGV[1]
endpoint = ARGV[2]
registry_endpoint = ARGV[3]

klass = Kernel
service_class.split('::').each do |name|
  klass = klass.const_get(name)   
end

if endpoint.end_with?(':0')
  port = 22000 + (Process.pid % 20000)
  endpoint = endpoint.dup
  endpoint[-1] = port.to_s
end
  
registry = Service::Platform::ServiceRegistryProxy.new registry_endpoint
begin
  service = klass.new registry
  service.start(endpoint)
  puts "STARTED"
  puts "." * 10240
  service.wait
ensure
  service.stop
end
