"use strict";

function LatLon(lat, lon) {
	this.lat = lat;
	this.lon = lon;
}

LatLon.OSM_PROJ = new OpenLayers.Projection("EPSG:900913");
LatLon.OUR_PROJ = new OpenLayers.Projection("EPSG:4326");

LatLon.fromLonLat = function(lonlat) {
	var ol = lonlat.transform(LatLon.OSM_PROJ, LatLon.OUR_PROJ);
	return new LatLon(lonlat.lat, lonlat.lon);	
}

LatLon.prototype.getLonLat = function() {
 	var ol = new OpenLayers.LonLat(this.lon, this.lat)
 	ol.transform(LatLon.OUR_PROJ, LatLon.OSM_PROJ);
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
	this.map.zoomTo(11);
	this.map.setCenter(centeredAt.getLonLat());
}

VesselMap.prototype.isCenteredAt = function(latlon) {
	var center = LatLon.fromLonLat(this.map.getCenter());
	return (latlon.lat == center.lat) && (latlon.lon == center.lon);
}

VesselMap.prototype.zoomToArea = function(latlon1, latlon2) {
	var bounds = new OpenLayers.Bounds();
	bounds.extend(latlon1.getLonLat());
	bounds.extend(latlon2.getLonLat());
	this.map.zoomToExtent(bounds);
}
