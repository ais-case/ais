describe("LatLon", function() {
	it("holds the lat and lon coordinates", function() {
		var latlon = new LatLon(52.0, 4.0);
		expect(latlon.lat).toEqual(52.0);
		expect(latlon.lon).toEqual(4.0);
	});
	
	it("can return OpenLayers coordinates", function() {
		var latlon = new LatLon(52, 4);
		ol = latlon.getOpenLayersLonLat();
		expect(ol.lat).toEqual(52.0);
		expect(ol.lon).toEqual(4.0);
	});
});
