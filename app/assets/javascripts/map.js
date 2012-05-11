
function loadMap() {
  OpenLayers.ImgPath = "/ol/img/"
  var map = new OpenLayers.Map({
      div: "map",
      layers: [
        new OpenLayers.Layer.OSM(),
      ],
      theme: "/ol/theme/style.css",
  });
  map.zoomToMaxExtent();
}
 
$(document).ready(loadMap);