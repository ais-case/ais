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