'use strict';

function Marker(id, position, icon) {
  if (!id || !position || !icon) {
    throw 'Incorrect number of arguments passed to Marker constructor';
  }
  this.id = id;
  this.position = position;
  this.icon = icon;
}

function Map(id, centeredAt, loader) {
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
  this.loader = loader;
}

Map.prototype.loadMarkers = function() {
  var self = this;
  var extent = this.map.getExtent().toArray();
  var lonlat1 = new OpenLayers.LonLat(extent[0], extent[1]);
  var lonlat2 = new OpenLayers.LonLat(extent[2], extent[3]);

  this.loader.loadMarkers(function(data) {
    var markers = data.markers;
    for (var i = 0; i < markers.length; i++) {
      var latlon = new LatLon(markers[i].position.lat, markers[i].position.lon);
      var marker = new Marker(markers[i].id, latlon, markers[i].icon);
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
  var size = new OpenLayers.Size(20, 20);
  var offset = new OpenLayers.Pixel(-(size.w / 2), -(size.h / 2));
  var icon = new OpenLayers.Icon(marker.icon, size, offset);
  var olMarker = new OpenLayers.Marker(marker.position.getLonLat(), icon);
  var self = this;
  olMarker.events.register('click', olMarker, function(evt) {
    var popup = new PopUp(marker, self.loader);
    popup.addToMap(self.map);
  });
  this.markerLayer.addMarker(olMarker);
};

Map.prototype.hasMarkerAt = function(latlon, icon) {
  var endsWith = function(str, suffix) {
    return (str.indexOf(suffix, str.length - suffix.length) !== -1);
  }

  for (var i = 0; i < this.markerLayer.markers.length; i++) {
    var marker = this.markerLayer.markers[i];
    var position = LatLon.fromLonLat(marker.lonlat);
    if (position.equals(latlon)) {
      if (!icon) {
        return true;
      } else if (endsWith(marker.icon.url, '_' + icon + '.png')) {
        return true;
      }
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
};
