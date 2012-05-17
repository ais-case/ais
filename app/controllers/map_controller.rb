class MapController < ApplicationController
  attr_writer :registry
  
  def get_registry
    @registry ||= ServiceRegistry.new
  end
  
  def markers
    registry = get_registry
    vessel_service = registry.bind 'ais/vessels'
    @vessels = vessel_service.vessels()
    registry.terminate
    
    @markers = @vessels.keep_if { |vessel| vessel.position }
    
    respond_to do |format| 
      format.json
    end
  end
end
