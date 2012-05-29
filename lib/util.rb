require 'logger'

module Util
  def get_log(progname)
    valid_levels = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL']
    logfile = File.dirname(__FILE__) << "/../log/log-#{progname}.log"
    log = Logger.new(logfile)
    if ENV.has_key?('LOGLEVEL')
      if valid_levels.include?(ENV['LOGLEVEL'])
        log.level = Logger::Severity.const_get(ENV['LOGLEVEL'])  
      else
        log.level = Logger::ERROR
        log.error("Invalid value for LOGLEVEL: #{ENV['LOGLEVEL']}")
      end
    else
      log.level = Logger::ERROR
    end
    log
  end
  
  module_function :get_log
end