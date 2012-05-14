describe("LatLon", function() {
	it("holds the lat and lon coordinates", function() {
		var latlon = new LatLon(52.0, 4.0);
		expect(latlon.lat).toEqual(52.0);
		expect(latlon.lon).toEqual(4.0);
	});
	
	it("can return OpenLayers OSM spherical mercator coordinates", function() {
		var latlon = new LatLon(52, 4);
		var ol = latlon.getLonLat();
		expect(ol.lat).toEqual(6800125.4534507);
		expect(ol.lon).toEqual(445277.96311111);
	});
	
	it("can be created from OSM spherical mercator coordinates", function() {
		var lonlat = {lat:52.0, lon:4.0, transform: function() {}}
		spyOn(lonlat, 'transform');
		var latlon = LatLon.fromLonLat(lonlat);
		expect(lonlat.transform).toHaveBeenCalled();
		expect(latlon.lat).toEqual(52.0);
		expect(latlon.lon).toEqual(4.0);
	});
});

describe("VesselMap", function() {
	it("checks whether it is centered at a given point", function() {
		var latlon = new LatLon(52, 4);
		var map = new VesselMap('map', latlon);
		expect(map.isCenteredAt(latlon)).toBeTruthy();
	});
});