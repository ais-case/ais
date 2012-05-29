'use strict';

function AjaxDataLoader(url) {
  this.url = url;
}

AjaxDataLoader.prototype.load = function(callback, latlon1, latlon2) {
  var url = this.url + '?area=';
  url += latlon1.lat + ',' + latlon1.lon;
  url += '_';
  url += latlon2.lat + ',' + latlon2.lon;
  
  jQuery.ajax(url, {
    'success': function(data, status, xhr) {
      callback(data);
    }
  });
};

