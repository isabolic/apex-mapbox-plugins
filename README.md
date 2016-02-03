Oracle apex plugins for google map API & mapbox API
- install:
- compile packages APEX_PLUGIN_PKG
- run install sql scripts for apex (region_xxx and item_xxx), also mapbox region plugin has own template
- then in shared components plugins upload js&css files
- on global page set GoogleApiKeyInclude or mapboxIncludeAPI and set your API key (google/mapbox)
- on your desired page set mapboxRegion/googleMap plugin (don't forget to set mapbox region template..)
