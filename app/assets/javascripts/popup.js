'use strict';

function PopUp(marker, loader) {
  this.marker = marker;
  this.loader = loader;
  this.popup = new OpenLayers.Popup(null, this.marker.position.getLonLat(), 
                        new OpenLayers.Size(200, 200), "Loading information...",
                        true);
}

PopUp.prototype.addToMap = function (map) {
  map.addPopup(this.popup);
  var self = this;
  
  this.loader.loadInfo(function(data) {
    self.popup.setContentHTML(data);  
  }, this.marker.id);
}
