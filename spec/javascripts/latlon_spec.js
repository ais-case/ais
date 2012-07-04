describe("LatLon", function() {
  it("holds the lat and lon coordinates", function() {
    var latlon = new LatLon(52.0, 4.0);
    expect(latlon.lat).toEqual(52.0);
    expect(latlon.lon).toEqual(4.0);
  });
  
  it("can return OpenLayers OSM spherical mercator coordinates", function() {
    var latlon = new LatLon(52, 4);
    var ol = latlon.getLonLat();
    expect(ol.lat).toBeCloseTo(6800125.45345, 5);
    expect(ol.lon).toBeCloseTo(445277.96311, 5);
  });
  
  it("can be created from OSM spherical mercator coordinates", function() {
    
    function Mock(lat, lon) {
      this.lat = lat;
      this.lon = lon;
    }
    
    Mock.prototype.transformed = 0;
    
    Mock.prototype.clone = function() {
      return new Mock(this.lat, this.lon);
    }
    
    Mock.prototype.transform = function() {
      Mock.prototype.transformed++;
      this.lat /= 10;
      this.lon /= 10;
      return this;
    }
    
    var lonlat = new Mock(520.0, 40.0);
    spyOn(lonlat, 'clone').andCallThrough();
    var latlon = LatLon.fromLonLat(lonlat);
    expect(lonlat.clone).toHaveBeenCalled();
    expect(Mock.prototype.transformed).toEqual(1);
    expect(latlon.lat).toEqual(52.0);
    expect(latlon.lon).toEqual(4.0);
    
    // Regression test, ensure transformation is performed
    // on a copy of the lonlat object to leave the original
    // object intact.
    latlon = LatLon.fromLonLat(lonlat);
    latlon = LatLon.fromLonLat(lonlat);
    expect(latlon.lat).toEqual(52.0);
    expect(latlon.lon).toEqual(4.0);
  });
  
  it("can check if it has equal values as another LonLat object", function() {
    var latlon1 = new LatLon(10,20);
    var latlon2 = new LatLon(10,20);
    var latlon3 = new LatLon(10,30);
    var latlon4 = new LatLon(20,20);
    var latlon5 = new LatLon(10.00005,20.00005);
    
    expect(latlon1.equals(latlon2)).toBeTruthy();
    expect(latlon2.equals(latlon1)).toBeTruthy();
    expect(latlon1.equals(latlon3)).toBeFalsy();
    expect(latlon1.equals(latlon4)).toBeFalsy();
    expect(latlon1.equals(latlon5)).toBeTruthy();
  });
});