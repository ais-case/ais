class MapController < ApplicationController
  attr_writer :registry
  
  def get_registry
    @registry ||= Service::Platform::ServiceRegistryProxy.new(Rails.configuration.registry_endpoint)
  end
  
  def markers
    latlon1 = latlon2 = nil
    if params[:area]
      pairs = params[:area].split('_').map { |p| p.split(',') }
      if pairs.length > 1
        latlon1 = Domain::LatLon.new(pairs[0][0].to_f, pairs[0][1].to_f)
        latlon2 = Domain::LatLon.new(pairs[1][0].to_f, pairs[1][1].to_f)
      end
    end
    
    logger.debug("Controller received marker request with latlons #{latlon1} and #{latlon2}")
    
    vessels = []
    registry = get_registry
    registry.bind('ais/vessel') do |service|
      if latlon1 and latlon2
        vessels = service.vessels(latlon1, latlon2)
      else
        vessels = service.vessels
      end
    end
    logger.debug("Controller received #{vessels.length} vessels")

    @markers = vessels.keep_if { |vessel| vessel.position }

    logger.debug("Controller generated #{@markers.length} markers")
    
    respond_to do |format| 
      format.json
    end
  end
end
