'use strict';

function AjaxDataLoader(baseUrl) {
  this.baseUrl = baseUrl;
}

AjaxDataLoader.prototype.loadMarkers = function(callback, latlon1, latlon2) {
  var url = this.baseUrl + 'markers?area=';
  url += latlon1.lat + ',' + latlon1.lon;
  url += '_';
  url += latlon2.lat + ',' + latlon2.lon;

  jQuery.ajax(url, {
    'success': function(data, status, xhr) {
      callback(data);
    }
  });
};

AjaxDataLoader.prototype.loadInfo = function(callback, info_id) {
  var url = this.baseUrl + 'info/' + info_id;

  jQuery.ajax(url, {
    'success': function(data, status, xhr) {
      callback(data);
    }
  });
};
