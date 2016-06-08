/**
 * [created by isabolic sabolic.ivan@gmail.com]
 */
(function($) {
    var options = {
        mapRegionId: null
    };

    /**
     * [triggerEvent     - PRIVATE handler fn - trigger apex events]
     * @param String evt - apex event name to trigger
     */
    var triggerEvent = function(evt, evtData) {
        this.container.trigger(evt, [evtData]);
    };

    apex.plugins.mapbox.MapBoxZoomToAdapter = function(opts) {
        this.region = null;
        this.apexname = "MAPBOXZOOMTOADAPTER";
        this.mapBoxMap = null;
        this.$items = {
            bboxItem : null,
            zoomLevelItem : null
        }
        this.init = function() {
            
            if ($.isPlainObject(options)) {
                this.options = $.extend(true, {}, this.options, options, opts);
            } else {
                throw "apex.plugins.MapBoxZoomToAdapter: Invalid options passed.";
            }

            if (this.options.mapRegionId === null) {
                throw "apex.plugins.MapBoxZoomToAdapter: mapRegionId is required.";
            }

            this.region = $("#" + this.options.mapRegionId);

            if (this.region.length !== 1) {
                throw "apex.plugins.MapBoxZoomToAdapter: Invalid region selector.";
            }

            this.mapBoxMap = this.region.data("mapboxRegion");
            
            if ($.isPlainObject(this.mapBoxMap) === false) {
                throw "apex.plugins.MapBoxZoomToAdapter: Can't access mapboxRegion region data.";
            }

            this.$items.zoomLevelItem = $("#" + this.options.zoomLevelItem);
        
            this.region.data("MapBoxZoomToAdapter", this);

            return this;
        }
        return this.init();
    };

    apex.plugins.mapbox.MapBoxZoomToAdapter.prototype = {
         zoomTo:function zoomTo(){
                if (this.$items.zoomLevelItem.val()){

                    this.mapBoxMap.zoomTo(this.$items.zoomLevelItem.val());
                }

                return this.zoomTo.bind(this);
         }
    };

})(apex.jQuery);