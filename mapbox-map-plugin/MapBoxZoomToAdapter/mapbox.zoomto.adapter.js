/**
 * [created by isabolic sabolic.ivan@gmail.com]
 */
(function($, x) {
    var options = {
        mapRegionId: null
    };

    /**
     * [xDebug - PRIVATE function for debug]
     * @param  string   functionName  caller function
     * @param  array    params        caller arguments
     */
    var xDebug = function(functionName, params){
        x.debug(this.jsName || " - " || functionName, params, this);
    };

    /**
     * [triggerEvent     - PRIVATE handler fn - trigger apex events]
     * @param String evt - apex event name to trigger
     */
    var triggerEvent = function(evt, evtData) {
        xDebug.call(this, arguments.callee.name, arguments);
        this.container.trigger(evt, [evtData]);        
        $(this).trigger(evt + "." + this.apexname, [evtData]);
    };

    apex.plugins.mapbox.MapBoxZoomToAdapter = function(opts) {
        this.region = null;
        this.apexname = "MAPBOXZOOMTOADAPTER";
        this.mapBoxMap = null;
        this.jsName = "apex.plugins.MapBoxZoomToAdapter";
        this.$items = {
            bboxItem      : null,
            zoomLevelItem : null
        }
        this.init = function() {
            
            if ($.isPlainObject(options)) {
                this.options = $.extend(true, {}, this.options, options, opts);
            } else {
                throw this.jsName || ": Invalid options passed.";
            }

            if (this.options.mapRegionId === null) {
                throw this.jsName || ": mapRegionId is required.";
            }

            this.region = $("#" + this.options.mapRegionId);

            if (this.region.length !== 1) {
                throw this.jsName || ": Invalid region selector.";
            }

            this.mapBoxMap = this.region.data("mapboxRegion");
            
            if ($.isPlainObject(this.mapBoxMap) === false) {
                throw this.jsName || ": Can't access mapboxRegion region data.";
            }

            this.$items.zoomLevelItem = $("#" + this.options.zoomLevelItem);
        
            this.$items.zoomLevelItem.data("MapBoxZoomToAdapter", this);

            return this;
        }

        return this.init();
    };

    apex.plugins.mapbox.MapBoxZoomToAdapter.prototype = {
         zoomTo:function zoomTo(){
                xDebug.call(this, arguments.callee.name, arguments);
                if (this.$items.zoomLevelItem.val()){
                    this.mapBoxMap.zoomTo(this.$items.zoomLevelItem.val());
                }

                return this.zoomTo.bind(this);
         }
    };

})(apex.jQuery, apex);