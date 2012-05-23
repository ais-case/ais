class MapController < ApplicationController
  attr_writer :registry
  
  def get_registry
    @registry ||= Service::Platform::ServiceRegistryProxy.new(Rails.configuration.registry_endpoint)
  end
  
  def markers
    vessels = []
    registry = get_registry
    registry.bind('ais/vessel') do |service|
      vessels = service.vessels()
    end

    @markers = vessels.keep_if { |vessel| vessel.position }
    
    respond_to do |format| 
      format.json
    end
  end
end
