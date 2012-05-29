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
	
	it("can check if it has equal values as another LonLat object", function() {
		var latlon1 = new LatLon(10,20);
		var latlon2 = new LatLon(10,20);
		var latlon3 = new LatLon(10,30);
		var latlon4 = new LatLon(20,20);
		
		expect(latlon1.equals(latlon2)).toBeTruthy();
		expect(latlon2.equals(latlon1)).toBeTruthy();
		expect(latlon1.equals(latlon3)).toBeFalsy();
		expect(latlon1.equals(latlon4)).toBeFalsy();
	});
});

describe("Marker", function() {
	it("has id and position property", function() {
		var latlon = new LatLon(52, 4);
		var marker = new Marker(42, latlon);
		expect(marker.id).toBe(42);
		expect(marker.position).toBe(latlon);
	});
});

describe("AjaxDataLoader", function() {
	var loader;
	
	beforeEach(function() {
		window.jQuery = {'ajax': function(url, settings) { 
			settings.success("TestData", "success", {}); 
		}};
		loader = new AjaxDataLoader("http://example.com/some/path");
	});

	it("requests data", function() {
    var latlon1 = new LatLon(52, 4);
    var latlon2 = new LatLon(52.1, 4.1);

		spyOn(window.jQuery, 'ajax').andCallThrough();
		loader.load(function() {}, latlon1, latlon2);
		expect(window.jQuery.ajax).toHaveBeenCalled();
		expect(window.jQuery.ajax.mostRecentCall.args[0]).toEqual("http://example.com/some/path?area=52,4_52.1,4.1");
	});
	
	it("calls the callback after receiving data", function() {
    var latlon1 = new LatLon(52, 4);
    var latlon2 = new LatLon(52.1, 4.1);

		var obj = {'cb': function (data) {}}
		spyOn(obj, 'cb');
		loader.load(obj.cb, latlon1, latlon2);
		expect(obj.cb).toHaveBeenCalledWith("TestData");
	});
});

describe("Map", function() {
  var latlon;
	var map;
	var marker;
	
	beforeEach(function() {
		latlon = new LatLon(52, 4);
		map = new Map('map', latlon);
		marker = new Marker(42, new LatLon(52, 4));		
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

		var loader = {'load': function(cb){
			cb({'markers':[{'position': new LatLon(52.1, 3.9)}, {'position': new LatLon(52.2, 3.8)}]});
		}};
		spyOn(loader, 'load').andCallThrough(); 
		map.loadMarkers(loader);
		expect(loader.load).toHaveBeenCalled();
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