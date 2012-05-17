class MapController < ApplicationController
  attr_writer :registry
  
  def get_registry
    @registry ||= ServiceRegistry.new
  end
  
  def markers
    registry = get_registry
    registry.bind('ais/vessels') do |service|
      @vessels = service.vessels()
    end
    registry.terminate
    
    @markers = @vessels.keep_if { |vessel| vessel.position }
    
    respond_to do |format| 
      format.json
    end
  end
end
