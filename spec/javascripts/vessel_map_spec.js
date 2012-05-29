describe("Marker", function() {
	it("has id and position property", function() {
		var latlon = new LatLon(52, 4);
		var marker = new Marker(42, latlon);
		expect(marker.id).toBe(42);
		expect(marker.position).toBe(latlon);
	});
});

describe("Map", function() {
  var latlon;
	var map;
	var marker;
	var loader;
	
	beforeEach(function() {
    marker = new Marker(42, new LatLon(52, 4));
		latlon = new LatLon(52, 4);
		
		loader = {
		  'loadMarkers': function(cb) {
		    cb({
		      'markers': [{'position': new LatLon(52.1, 3.9)}, {'position': new LatLon(52.2, 3.8)}]
		    });
		  },
		}		

    map = new Map('map', latlon, loader);
	});
	
	it("checks whether it is centered at a given point", function() {
		expect(map.isCenteredAt(new LatLon(52, 4))).toBeTruthy();
	});
	
	it("can zoom into an area", function() {
		var latlon1 = new LatLon(52, 4);
		var latlon2 = new LatLon(52.1, 4.1);
		map.zoomToArea(latlon1, latlon2);
	});
	
	it("allows adding markers", function() {
		map.addMarker(marker);
		expect(map.markerLayer.markers.length).toBe(1);
	});

	it("checks whether a marker is at a given location", function() {
		map.addMarker(marker);
		expect(map.hasMarkerAt(new LatLon(52, 4))).toBeTruthy();
	});
	
	it("loads markers", function() {
    var latlon1 = new LatLon(52, 4);
    var latlon2 = new LatLon(52.1, 4.1);
    map.zoomToArea(latlon1, latlon2);

		spyOn(loader, 'loadMarkers').andCallThrough(); 
		map.loadMarkers();
		expect(loader.loadMarkers).toHaveBeenCalled();
		expect(map.markerLayer.markers.length).toBe(2);
	});
	
	it("can trigger the click event of a marker", function() {
	  var handler = jasmine.createSpy('handler');

    map.addMarker(marker);
    var osmMarker = map.markerLayer.markers[0];
    osmMarker.events.register('click', osmMarker, handler);
    
	  map.clickMarker(latlon);
	  expect(handler).toHaveBeenCalled();
	});
});