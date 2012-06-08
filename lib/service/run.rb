#!/usr/bin/env ruby

require_relative 'platform/service_registry_proxy'

args = Marshal.load(STDIN.readline)

require_relative args[0]
service_class = args[1]
endpoint = args[2]
registry_endpoint = args[3]

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
rescue
  $stderr.puts $!
ensure
  service.stop
end
