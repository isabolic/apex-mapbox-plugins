/**
 * [created by isabolic sabolic.ivan@gmail.com]
 */
(function($, x) {
    var options = {
        mapRegionId : null,
        apexItem    : null,
        style       : null,
        zoomTo      : false
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

    apex.plugins.mapbox.MapBoxLoadGeometryAdapter = function(opts) {
        this.region    = null;
        this.apexname  = "MAPBOXLOADGEOMETRYADAPTER";
        this.mapBoxMap = null;
        this.jsName    = "apex.plugins.MapBoxLoadGeometryAdapter";
        this.$items    = {
            apexItem : null
        }
        this.init = function() {

            if ($.isPlainObject(options)) {
                this.options = $.extend(true, {}, this.options, options, opts);
            } else {
                throw this.jsName + ": Invalid options passed.";
            }

            if (this.options.mapRegionId === null) {
                throw this.jsName + ": mapRegionId is required.";
            }

            this.region = $("#" + this.options.mapRegionId);

            if (this.region.length !== 1) {
                throw this.jsName + ": Invalid region selector.";
            }

            this.mapBoxMap = this.region.data("mapboxRegion");

            if ($.isPlainObject(this.mapBoxMap) === false) {
                throw this.jsName + ": Can't access mapboxRegion region data.";
            }

            this.$items.apexItem = $("#" + this.options.apexItem);
            this.$items.apexItem.data("MapBoxLoadGeometryAdapter", this);

            return this;
        }
        return this.init();
    };

    apex.plugins.mapbox.MapBoxLoadGeometryAdapter.prototype = {

        /**
         * [loadFromAjax load geomtry from ajax]
         * @param  Object idVal unique identifier for geometry fetch
         * @return this
         */
        loadFromAjax: function loadFromAjax(idVal) {            
            var queryString = {
                p_flow_id      : $('#pFlowId').val(),
                p_flow_step_id : $('#pFlowStepId').val(),
                p_instance     : $('#pInstance').val(),
                x01            : idVal || this.$items.apexItem.val(),
                p_request      : 'PLUGIN=' + this.options.ajaxIdentifier
            };

            xDebug.call(this, arguments.callee.name, arguments);

            $.ajax({
                type     : 'POST',
                url      : 'wwv_flow.show',
                data     : queryString,
                dateType : 'application/json',
                async    : true,
                success  : function(data) {
                    x.debug('Ajax get data request successful');
                    x.debug('geojson : ' || data);
                    this.loadGeometry(data);
                }.bind(this)
            });

            return this;
        },

        /**
         * [loadGeometry description]
         * @param  object   data  geojson
         * @param  object   style json style config
         * @return this
         */
        loadGeometry: function loadGeometry(data, style) {
            var geoJson;
            xDebug.call(this, arguments.callee.name, arguments);
            if (data) {
                if ($.isPlainObject(data) === false) {
                    geoJson = $.parseJSON(data);
                }

                if (this.options.style && $.isEmptyObject(this.options.style) === false) {
                    geoJson.properties = style || this.options.style;
                }

                this.mapBoxMap.setGeoJSON(geoJson, this.options.zoomTo);
            }

            return this;
        }
    };

})(apex.jQuery, apex);
