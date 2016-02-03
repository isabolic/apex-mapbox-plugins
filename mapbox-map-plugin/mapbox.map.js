
function mapBoxMap(pRegionId, mapName) {
    var $ = apex.jQuery, region = $("#" + pRegionId);

    if(region.length !== 1) {
      throw "mapBoxMap: Invalid region selector";
    }
    
    region.addClass("mapbox-map");
    // Create a map in the div #map
    L.mapbox.map(region.get(0), 'mapbox.streets');
}
