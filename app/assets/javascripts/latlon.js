'use strict';

function LatLon(lat, lon) {
  this.lat = lat;
  this.lon = lon;
}

LatLon.OSM_PROJ = new OpenLayers.Projection('EPSG:900913');
LatLon.OUR_PROJ = new OpenLayers.Projection('EPSG:4326');

LatLon.fromLonLat = function(lonlat) {
  var ol = lonlat.transform(LatLon.OSM_PROJ, LatLon.OUR_PROJ);
  return new LatLon(lonlat.lat, lonlat.lon);
};

LatLon.prototype.getLonLat = function() {
  var ol = new OpenLayers.LonLat(this.lon, this.lat);
  ol.transform(LatLon.OUR_PROJ, LatLon.OSM_PROJ);
  return ol;
};

LatLon.prototype.equals = function(that) {
  return ((this.lat == that.lat) && (this.lon == that.lon));
};
