require 'logger'

module Util
  def get_log(progname)
    logfile = File.dirname(__FILE__) << "/../log/log-#{progname}.log"
    log = Logger.new(logfile)
    if ENV.has_key?('LOGLEVEL') and Logger::Severity.const_defined?(ENV['LOGLEVEL']) 
      log.level = Logger::Severity.const_get(ENV['LOGLEVEL'])
    else
      log.level = Logger::WARN
    end
    log
  end
  
  module_function :get_log
end