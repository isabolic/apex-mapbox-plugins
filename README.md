Oracle apex plugins for & mapbox API
- install:
- compile packages APEX_PLUGIN_PKG
- run install sql scripts for apex (region_xxx and item_xxx)
- then in shared components plugins upload js&css files (or on apache host folder)
- on global page set mapBoxIncludeAPI and set your API key (mapbox)
- on your desired page set mapboxRegion (don't forget to set mapbox region template..)

DOCS:
mapBoxIncludeAPI:
   - "API key"    : mapbox API key

mapboxRegion (requires mapBoxIncludeAPI):
   - Attributes:
     - "Map name"   : name of mapbox map
     - "Width"      : map width   (px, auto.. css value)
     - "Height"     : map height  (px, auto.. css value)
     - "initalView" : json object for inital position - {x:45.793533,y:16.004514,zoomLevel:9}
   - Events:
     - mapBoxMap change zoomLevel [mapBoxRegion] - after current zoom level chnage
     - mapBoxMap change bbox [mapBoxRegion]      - after current bbox change 
   - access in js console: apex.plugins.mapbox.map

   CL:
   mapboxRegion:
   - supported maximize region - template option
   
example:
    https://apex.oracle.com/pls/apex/f?p=101959:2

