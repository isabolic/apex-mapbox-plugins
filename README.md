Oracle apex plugins for & mapbox API
- install:
- compile packages APEX_PLUGIN_PKG
- run install sql scripts for apex (region_xxx and item_xxx)
- then in shared components plugins upload js&css files (or on apache host folder)
- on global page set mapBoxIncludeAPI and set your API key (mapbox)
- on your desired page set mapboxRegion (don't forget to set mapbox region template..)
- remove in plugins file url calls (etc http://playground/ws/mapbox.map.css and http://playground/ws/mapbox.map.js)

DOCS:
mapBoxIncludeAPI:
   - "API key"    : mapbox API key

mapboxRegion (requires mapBoxIncludeAPI):
   - access in js console: apex.plugins.mapbox.map
   - Attributes:
     - "Map name"   : name of mapbox map
     - "Width"      : map width   (px, auto.. css value)
     - "Height"     : map height  (px, auto.. css value)
     - "initalView" : json object for inital position - {x:45.793533,y:16.004514,zoomLevel:9}
   - Events:
     - mapBoxMap change zoomLevel [mapBoxRegion] - after current zoom level chnage
     - mapBoxMap change bbox [mapBoxRegion]      - after current bbox change 
     - mapBoxMap maximize region [mapBoxRegion]  - after region (map) maximize/ return to previous height/width
   - api method:
     - zoomTo (etc. apex.plugins.mapbox.map.zoomTo) - zoom to spec. postion on map (params: x,y,zoomlevel)

   CL:
   mapboxRegion:
   - supported maximize region - template option
   - event "mapBoxMap maximize region [mapBoxRegion]"
   
example:
    https://apex.oracle.com/pls/apex/f?p=101959:2

