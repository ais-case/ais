describe("Map page", function() {
	describe("parseLocations", function() {

		var expectLatLon = function(obj, lat, lon) {
			expect(obj.lat).toEqual(lat);
			expect(obj.lon).toEqual(lon);
		}
		var expectLatLons = function(arr) {
			for (var i = 0; i < arr.length; i++) {
				expectLatLon(arr[i], arguments[2*i+1], arguments[2*i+2])
			}
		}
		
		it("can parse two pairs of coordinates", function() {
			var locs = parseLocations("1.0,2.0_3.0,4.0");
			expectLatLons(locs, 1.0, 2.0, 3.0, 4.0);
		});
		
		it("can parse integer coordinates", function() {
			var locs = parseLocations("1,2_3,4");
			expectLatLons(locs, 1.0, 2.0, 3.0, 4.0);
		});
		
		it("can parse negative coordinates", function() {
			var locs = parseLocations("-1,2_3,-4");
			expectLatLons(locs, -1.0, 2.0, 3.0, -4.0);
		});

		it("throws an exception for invalid locations", function() {
			expect(function() {parseLocations("")}).toThrow("Invalid coordinates");
			expect(function() {parseLocations("1,2,3,4")}).toThrow("Invalid coordinates");			
			expect(function() {parseLocations("1_3,4")}).toThrow("Invalid coordinates");	
			expect(function() {parseLocations("1,2_3,4_6,5")}).toThrow("Invalid location");			
		});

	});
});