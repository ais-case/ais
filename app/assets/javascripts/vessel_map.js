'use strict';

function Marker(id, position, icon) {
  if (!id || !position || !icon) {
    throw 'Incorrect number of arguments passed to Marker constructor';
  }
  this.id = id;
  this.position = position;
  this.icon = icon;
  this.line = null;
}

Marker.prototype.addLine = function(direction, length) {
  this.line = {'direction': direction, 'length': length, 
               'position': this.position};
};

function Map(id, centeredAt, loader) {
  this.markerLayer = new OpenLayers.Layer.Markers('Markers');
  this.lineLayer = new OpenLayers.Layer.Vector('Lines');

  OpenLayers.ImgPath = '/ol/img/';
  this.map = new OpenLayers.Map({
    div: id,
    layers: [
      new OpenLayers.Layer.OSM(),
      this.markerLayer,
      this.lineLayer,
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
      if (markers[i].line) {
        marker.addLine(markers[i].line.direction, markers[i].line.length);
      }
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
  
  // Add OpenLayers marker to marker layer
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
  
  // Add OpenLayers LineString to line layer
  if (marker.line && marker.line.length > 0.01) { 
    var length = marker.line.length;
    var angle = Math.PI * (marker.line.direction / 180.0);
    var dx = length * Math.sin(angle);
    var dy = length * Math.cos(angle);

    var lonlat1 = marker.position.getLonLat();
    var lonlat2 = new LatLon(marker.position.lat + dy, marker.position.lon + dx).getLonLat();
    var p1 = new OpenLayers.Geometry.Point(lonlat1.lon, lonlat1.lat);
    var p2 = new OpenLayers.Geometry.Point(lonlat2.lon + dx, lonlat2.lat + dy);
    var line = new OpenLayers.Geometry.LineString([p1, p2]);
    var feature = new OpenLayers.Feature.Vector(line);
    this.lineLayer.addFeatures([feature]);
  }
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

Map.prototype.getLineLength = function(latlon) {
  // Find a line feature where one of the two points is the 
  // given latlon
  var lineFound = null;
  for (var i = 0; i < this.lineLayer.features.length; i++) {
    var line = this.lineLayer.features[i].geometry;
    var points = line.getVertices(true);
    for (var j = 0; j < points.length; j++) {
      var lonlat = new OpenLayers.LonLat(points[j].x, points[j].y);
      var point = LatLon.fromLonLat(lonlat);
      if (point.lon == latlon.lon && point.lat == latlon.lat) {
        lineFound = line;
        break;
      }
    }
  }
  
  if (lineFound == null) {
    return null;
  } else {
    var points = line.getVertices(true);
    if (points.length != 2) {
      throw "Feature is not a line";
    }
    var lonlat1 = new OpenLayers.LonLat(points[0].x, points[0].y);
    var lonlat2 = new OpenLayers.LonLat(points[1].x, points[1].y);
    var point1 = LatLon.fromLonLat(lonlat1);
    var point2 = LatLon.fromLonLat(lonlat2);

    return Math.sqrt(Math.pow(point1.lon - point2.lon, 2) + 
                     Math.pow(point1.lat - point2.lat, 2));     
  }
};
