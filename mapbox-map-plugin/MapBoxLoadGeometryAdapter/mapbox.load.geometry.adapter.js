/**
 * [created by isabolic sabolic.ivan@gmail.com]
 */
(function($) {
    var options = {
        mapRegionId:null,
        apexItem   :null,
        style      :null,
        zoomTo     :false
    };

    /**
     * [triggerEvent     - PRIVATE handler fn - trigger apex events]
     * @param String evt - apex event name to trigger
     */
    var triggerEvent = function(evt, evtData) {
        this.container.trigger(evt, [evtData]);
    };

    apex.plugins.mapbox.MapBoxLoadGeometryAdapter = function(opts) {
        this.region = null;
        this.apexname = "MapBoxLoadGeometryAdapter";
        this.mapBoxMap = null;
        this.$items = {
            bboxItem : null,
            zoomLevelItem : null
        }
        this.init = function() {
            
            if ($.isPlainObject(options)) {
                this.options = $.extend(true, {}, this.options, options, opts);
            } else {
                throw "apex.plugins.MapBoxLoadGeometryAdapter: Invalid options passed.";
            }

            if (this.options.mapRegionId === null) {
                throw "apex.plugins.MapBoxLoadGeometryAdapter: mapRegionId is required.";
            }

            this.region = $("#" + this.options.mapRegionId);

            if (this.region.length !== 1) {
                throw "apex.plugins.MapBoxLoadGeometryAdapter: Invalid region selector.";
            }

            this.mapBoxMap = this.region.data("mapboxRegion");
            
            if ($.isPlainObject(this.mapBoxMap) === false) {
                throw "apex.plugins.MapBoxLoadGeometryAdapter: Can't access mapboxRegion region data.";
            }

            this.$items.geometry = $("#" + this.options.apexItem);            
            this.$items.geometry.data("MapBoxLoadGeometryAdapter", this);

            return this;
        }
        return this.init();
    };

    apex.plugins.mapbox.MapBoxLoadGeometryAdapter.prototype = {
         loadGeometry:function loadGeometry(){
                var geoJson = this.$items.geometry.val();
                if (geoJson){
                    if($.isPlainObject(geoJson) === false){
                        geoJson = $.parseJSON(geoJson);
                    }

                    if(this.options.style && $.isEmptyObject(this.options.style) === false){
                        geoJson.properties = this.options.style;
                    }

                    this.mapBoxMap.setGeoJSON(geoJson, this.options.zoomTo);
                }

                return this.loadGeometry.bind(this);
         }
    };

})(apex.jQuery);