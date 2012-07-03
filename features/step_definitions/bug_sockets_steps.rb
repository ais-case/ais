When /^wait (\d+) seconds$/ do |seconds_str|
  sleep(seconds_str.to_i)
end

Then /^there should be only one connection to the vessel service$/ do
  endpoint = @registry.lookup('ais/vessel')
  match = /:(?<port>\d+)$/.match(endpoint)
  match.should_not be_false
  port = match[:port]
  netstat = `netstat -an | grep #{port} | grep -v LISTEN`
  netstat.lines.count.should eq(1)
end