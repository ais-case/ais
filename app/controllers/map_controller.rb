class MapController < ApplicationController
  attr_writer :registry, :vessel_service
  
  def get_registry
    @registry ||= Service::Platform::ServiceRegistryProxy.new(Rails.configuration.registry_endpoint)
  end
  
  def vessel_service
    @vessel_service ||= Service::VesselProxySingleton.instance 
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
    
    if latlon1 and latlon2
      vessels = vessel_service.vessels(latlon1, latlon2)
    else
      vessels = vessel_service.vessels
    end
    logger.debug("Controller received #{vessels.length} vessels")

    filtered_vessels = vessels.keep_if { |vessel| vessel.position }
    @markers = filtered_vessels.map { |v| MarkerFactory.from_vessel(v) }

    logger.debug("Controller generated #{@markers.length} markers")
    
    respond_to do |format| 
      format.json
    end
  end
  
  def info
    logger.debug("Controller received info request for #{params[:id]}")
    
    @vessel = vessel_service.info(params[:id].to_i)

    respond_to do |format| 
      format.html { render :layout => false }
    end
  end
end
