"use strict";
var map = null;

var parseLocations = function(s) {
	var pair = s.split('_').map(function(loc) {
		var coords = loc.split(',').map(parseFloat);
		if (coords.length != 2) throw "Invalid coordinates";
		return new LatLon(coords[0], coords[1]);
	});
	if (pair.length != 2) throw "Invalid location";
	return pair;
}

$(document).ready(function() {
	map = new VesselMap('map', new LatLon(52.1,3.9))
	var locations;
	try {
		locations = parseLocations(window.location.hash.substring(1));
	} catch (err) {
		locations = null;
	}
	if (locations != null) {
		map.zoomToArea(locations[0], locations[1]);
	}
});