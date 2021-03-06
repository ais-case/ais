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
  
  function getTileURL(bounds) {
    var res = this.map.getResolution();
    var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
    var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
    var z = this.map.getZoom();
    var limit = Math.pow(2, z);
    if (y < 0 || y >= limit) {
      return null;
    } else {
      x = ((x % limit) + limit) % limit;
      var url = this.url;
      var path= z + "/" + x + "/" + y + "." + this.type;
      if (url instanceof Array) {
        url = this.selectUrl(path, url);
      }
      return url + path;
    }
  }

  OpenLayers.ImgPath = '/ol/img/';
  this.map = new OpenLayers.Map({
    div: id,
    projection: new OpenLayers.Projection("EPSG:900913"),
    layers: [
      new OpenLayers.Layer.OSM(),
      // new OpenLayers.Layer.TMS("Seezeichen", "http://tiles.openseamap.org/seamark/",
      //  { numZoomLevels: 18, type: 'png', getURL: getTileURL, isBaseLayer: false, displayOutsideMaxExtent: true}),
      this.markerLayer,
    ],
    controls: [
            new OpenLayers.Control.Navigation(),
            new OpenLayers.Control.PanZoomBar()],
    theme: 'ol/theme/default/style.css'
  });
  
  this.map.zoomTo(11);
  this.map.setCenter(centeredAt.getLonLat());
  this.loader = loader;
  this.lines = [];
  this.icon = {width: 25, height: 25}
}

Map.prototype.loadMarkers = function() {
  var self = this;
  var extent = this.map.getExtent().toArray();
  var lonlat1 = new OpenLayers.LonLat(extent[0], extent[1]);
  var lonlat2 = new OpenLayers.LonLat(extent[2], extent[3]);

  this.loader.loadMarkers(function(data) {
    var prevMarkerLayer = self.markerLayer; 
  
    self.markerLayer = new OpenLayers.Layer.Markers('Markers');
    self.map.addLayer(self.markerLayer);
    $(self.markerLayer.div).hide();
    
    var markers = data.markers;
    for (var i = 0; i < markers.length; i++) {
      var latlon = new LatLon(markers[i].position.lat, markers[i].position.lon);
      var marker = new Marker(markers[i].id, latlon, markers[i].icon);
      if (markers[i].line) {
        marker.addLine(markers[i].line.direction, markers[i].line.length);
      }
      self.addMarker(marker);
    }  

    $(self.markerLayer.div).show();
    $(prevMarkerLayer.div).hide();
    if (prevMarkerLayer != null) {
        for (var i = prevMarkerLayer.markers.length - 1; i >= 0; i--) {
            prevMarkerLayer.markers[i].destroy();
        }
        prevMarkerLayer.destroy();
    }
          
    setTimeout(function() {self.loadMarkers();}, 1000);
  }, LatLon.fromLonLat(lonlat1), LatLon.fromLonLat(lonlat2));
};

Map.prototype.isCenteredAt = function(latlon) {
  var center = LatLon.fromLonLat(this.map.getCenter());
  return (Math.abs(latlon.lat - center.lat) < 0.0001) && 
    (Math.abs(latlon.lon - center.lon) < 0.0001);
};

Map.prototype.zoomToArea = function(latlon1, latlon2) {
  var bounds = new OpenLayers.Bounds();
  bounds.extend(latlon1.getLonLat());
  bounds.extend(latlon2.getLonLat());
  this.map.zoomToExtent(bounds);
};

Map.prototype.addMarker = function(marker) {
  
  // Add OpenLayers marker to marker layer
  var size = new OpenLayers.Size(this.icon.width, this.icon.height);
  var offset = new OpenLayers.Pixel(-(this.icon.width / 2), -(this.icon.height / 2));
  var icon = new OpenLayers.Icon(marker.icon, size, offset);
  var olMarker = new OpenLayers.Marker(marker.position.getLonLat(), icon);
  var self = this;
  olMarker.events.register('click', olMarker, function(evt) {
    var popup = new PopUp(marker, self.loader);
    popup.addToMap(self.map);
  });
  this.markerLayer.addMarker(olMarker);
  
  if (marker.line && marker.line.length > 0.01) {
    var icon = $(icon.imageDiv);
    var canvasId = icon.attr('id') + '_canvas';
    icon.append('<canvas id="' + canvasId + '" class="marker_canvas" width="150" height="150"></canvas>');
        
    var length = marker.line.length;
    var angle = Math.PI * (marker.line.direction / 180.0);
    var sx = (this.icon.width / 2 - 2) * Math.sin(angle);
    var sy = -(this.icon.height / 2 - 2) * Math.cos(angle); 
    var dx = length * Math.sin(angle);
    var dy = -length * Math.cos(angle);

    var canvas = document.getElementById(canvasId);
    if (canvas) {
      var ctx = canvas.getContext('2d');
      ctx.beginPath();
      ctx.moveTo(75 + sx, 75 + sy);
      ctx.lineTo(75 + sx + dx, 75 + sy + dy);
      ctx.stroke();
    }
    
    this.lines.push({latlon: marker.position, dx: dx, dy: dy});      
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
      } else if (marker.icon.url.indexOf('_' + icon + '_') !== -1) {
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
  for (var i = 0; i < this.lines.length; i++) {
    var line = this.lines[i];
    if (line.latlon == latlon) {
      return Math.sqrt(Math.pow(line.dx, 2) + 
                       Math.pow(line.dy, 2));     
    }
  }  
  return null;
};
