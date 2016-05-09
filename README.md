Oracle apex plugins for google map API & mapbox API
- install:
- compile packages APEX_PLUGIN_PKG
- run install sql scripts for apex (region_xxx and item_xxx)
- then in shared components plugins upload js&css files (or on apache host folder)
- on global page set mapBoxIncludeAPI and set your API key (mapbox)
- on your desired page set mapboxRegion (don't forget to set mapbox region template..)

DOCS:
mapBoxIncludeAPI:
   - "API key"    : mapbox API key

mapboxRegion:
   - Attributes:
   - "Map name"   : name of mapbox map
   - "Width"      : map width   (px, auto.. css value)
   - "Height"     : map height  (px, auto.. css value)
   - "initalView" : json object for inital position - {x:45.793533,y:16.004514,zoomLevel:9}
access in js console: apex.plugins.mapbox.map

