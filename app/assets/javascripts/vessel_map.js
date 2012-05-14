"use strict";

function LatLon(lat, lon) {
	this.lat = lat;
	this.lon = lon;	
}

LatLon.prototype.getOpenLayersLonLat = function() {
	var ol = new OpenLayers.LonLat(this.lon, this.lat)
	return ol;
}

function VesselMap(id, centeredAt) {
    OpenLayers.ImgPath = "/ol/img/"
	this.map = new OpenLayers.Map({
		div: id,
		layers: [
			new OpenLayers.Layer.OSM(),
		],
		theme: "ol/theme/style.css",
	});	
	this.map.zoomToMaxExtent();
}

VesselMap.prototype.isCenteredAt = function(latlon) {
	var bounds = this.map.getExtent();
	console.log(bounds)
	return bounds.containsLonLat(latlon.getOpenLayersLonLat);
}