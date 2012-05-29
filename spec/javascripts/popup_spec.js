describe("Popup", function() {
  var loader;
  var marker;
  var map;
  
  beforeEach(function() {
    loader = {'loaded': false, 'loadInfo': function(cb, id){
      cb('Example body.');
      this.loaded = true;
    }};
    
    marker = new Marker(33, new LatLon(10, 20));
    map = {'addPopup': function(popup) {}}
  });
  
  it("shows a waiting text", function() {
    var popup = new PopUp(marker, loader);
    expect(popup.popup.contentHTML).toBe("Loading information...")
  });

  it("can be added to a map", function() {
    var popup = new PopUp(marker, loader);
    spyOn(map, 'addPopup')
    popup.addToMap(map)
    expect(map.addPopup).toHaveBeenCalled();
  });

  it("loads and shows content with the loader", function() {
    var popup = new PopUp(marker, loader);
    popup.addToMap(map)
    expect(loader.loaded).toBeTruthy()
    expect(popup.popup.contentHTML).toBe("Example body.")
  });
});
