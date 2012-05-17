class MapController < ApplicationController
  attr_writer :service
  
  def get_service
    @service ||= Service.new
  end
  
  def markers
    service = get_service
    vessel_service = service.bind 'ais/vessels'
    @vessels = vessel_service.vessels()
    service.terminate
    
    @markers = @vessels.keep_if { |vessel| vessel.position }
    
    respond_to do |format| 
      format.json
    end
  end
end
