describe("VesselMap", function() {
	it("checks whether it is centered at a given point", function() {
		var latlon = new LatLon(52, 4);
		var map = new VesselMap('map', latlon);
		expect(map.isCenteredAt(latlon)).toBeTruthy();
	});
});
