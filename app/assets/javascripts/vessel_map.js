'use strict';

function Marker(id, position) {
  this.id = id;
  this.position = position;
}

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
  var extent = this.map.getExtent().toArray();
  var lonlat1 = new OpenLayers.LonLat(extent[0], extent[1])
  var lonlat2 = new OpenLayers.LonLat(extent[2], extent[3])

  loader.load(function(data) {
    var markers = data.markers;
    for (var i = 0; i < markers.length; i++) {
      var marker = new Marker(markers[i].id, new LatLon(markers[i].position.lat, markers[i].position.lon));
      self.addMarker(marker);
    }
  }, LatLon.fromLonLat(lonlat1), LatLon.fromLonLat(lonlat2));
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
  osmMarker.events.register('click', osmMarker, function(evt) {
    marker.id;
  });
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

Map.prototype.clickMarker = function(latlon) {
  for (var i = 0; i < this.markerLayer.markers.length; i++) {
    var marker = this.markerLayer.markers[i];
    var position = LatLon.fromLonLat(marker.lonlat);
    if (position.equals(latlon)) {
      $(marker.icon.imageDiv).click();
    }
  }
}
