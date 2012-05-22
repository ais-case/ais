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

function Marker(position) {
  this.position = position;
}

function AjaxDataLoader(url) {
  this.url = url;
}

AjaxDataLoader.prototype.load = function(callback) {
  jQuery.ajax(this.url, {
    'success': function(data, status, xhr) {
      callback(data);
    }
  });
};

function Map(id, centeredAt) {
  this.markerLayer = new OpenLayers.Layer.Markers('Markers');

  OpenLayers.ImgPath = '/ol/img/';
  this.map = new OpenLayers.Map({
    div: id,
    layers: [
      new OpenLayers.Layer.OSM(),
      this.markerLayer
    ],
    theme: 'ol/theme/style.css'
  });
  this.map.zoomTo(11);
  this.map.setCenter(centeredAt.getLonLat());
}

Map.prototype.loadMarkers = function(loader) {
  var self = this;
  loader.load(function(data) {    
    var markers = data.markers;
    for (var i = 0; i < markers.length; i++) {
      var marker = new Marker(new LatLon(markers[i].position.lat, markers[i].position.lon));
      self.addMarker(marker);
    }
  });
};

Map.prototype.isCenteredAt = function(latlon) {
  var center = LatLon.fromLonLat(this.map.getCenter());
  return (latlon.lat == center.lat) && (latlon.lon == center.lon);
};

Map.prototype.zoomToArea = function(latlon1, latlon2) {
  var bounds = new OpenLayers.Bounds();
  bounds.extend(latlon1.getLonLat());
  bounds.extend(latlon2.getLonLat());
  this.map.zoomToExtent(bounds);
};

Map.prototype.addMarker = function(marker) {
  var osmMarker = new OpenLayers.Marker(marker.position.getLonLat());
  this.markerLayer.addMarker(osmMarker);
};

Map.prototype.hasMarkerAt = function(latlon) {
  for (var i = 0; i < this.markerLayer.markers.length; i++) {
    var position = LatLon.fromLonLat(this.markerLayer.markers[i].lonlat);
    if (position.equals(latlon)) {
      return true;
    }
  }
  return false;
};
