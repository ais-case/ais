describe("AjaxDataLoader", function() {
  var loader;
  
  beforeEach(function() {
    window.jQuery = {'ajax': function(url, settings) { 
      settings.success("TestData", "success", {}); 
    }};
    loader = new AjaxDataLoader("http://example.com/path/");
  });

  describe("loadMarkers", function() {
    it("requests data", function() {
      var latlon1 = new LatLon(52, 4);
      var latlon2 = new LatLon(52.1, 4.1);
  
      spyOn(window.jQuery, 'ajax').andCallThrough();
      loader.loadMarkers(function() {}, latlon1, latlon2);
      expect(window.jQuery.ajax).toHaveBeenCalled();
      expect(window.jQuery.ajax.mostRecentCall.args[0]).toEqual("http://example.com/path/markers?area=52,4_52.1,4.1");
    });
    
    it("calls the callback after receiving data", function() {
      var latlon1 = new LatLon(52, 4);
      var latlon2 = new LatLon(52.1, 4.1);
  
      var obj = {'cb': function (data) {}}
      spyOn(obj, 'cb');
      loader.loadMarkers(obj.cb, latlon1, latlon2);
      expect(obj.cb).toHaveBeenCalledWith("TestData");
    });    
  });

  describe("loadInfo", function() {
    it("requests data", function() {
      spyOn(window.jQuery, 'ajax').andCallThrough();
      loader.loadInfo(function() {}, 35);
      expect(window.jQuery.ajax).toHaveBeenCalled();
      expect(window.jQuery.ajax.mostRecentCall.args[0]).toEqual("http://example.com/path/info/35");
    });
    
    it("calls the callback after receiving data", function() {
      var obj = {'cb': function (data) {}}
      spyOn(obj, 'cb');
      loader.loadInfo(obj.cb, 35);
      expect(obj.cb).toHaveBeenCalledWith("TestData");
    });    
  });
});