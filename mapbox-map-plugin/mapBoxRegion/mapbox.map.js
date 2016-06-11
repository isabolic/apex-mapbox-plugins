/**
 * [created by isabolic sabolic.ivan@gmail.com]
 */
(function($) {
    var options = {
        mapRegionContainer: null,
        mapRegionId: null,
        mapName: null,
        width: "100%",
        height: 300,
        initalView: {
            x: null,
            y: null,
            zoomLevel: null
        }
    };

    /**
     * [triggerEvent     - PRIVATE handler fn - trigger apex events]
     * @param String evt - apex event name to trigger
     */
    var triggerEvent = function(evt, evtData) {
        this.container.trigger(evt, [evtData]);
    };

    /**
     * [resizeMap        - PRIVATE event handler fn -  when map bbox change]
     * @param String evt - apex event name to trigger
     */
    var bboxChangeEvt = function(evt) {
        var bbox = this.map.getBounds(),
            bboxJson = {
                "west": bbox.getWest(),
                "south": bbox.getSouth(),
                "east": bbox.getEast(),
                "north": bbox.getNorth(),
                "string": "BBOX(" + this.map.getBounds().toBBoxString() + ")"
            };

        triggerEvent.apply(this, [evt, bboxJson]);
    };

    /**
     * [zoomLlvChangeEvt - PRIVATE event handler fn - when map zoom level change]
     * @param String evt - apex event name to trigger
     */
    var zoomLlvChangeEvt = function(evt) {
        var lvl = {
            "zoomLevel": this.map.getZoom()
        }
        triggerEvent.apply(this, [evt, lvl]);
    };

    /**
     * [resizeMap        - PRIVATE event handler fn]
     * @param String evt - apex event name to trigger
     */
    var resizeMap = function (evt){
        var o = {
            w:this.region.width(),
            h:this.region.height(),
        }, 
        timer, 
        bounds = this.map.getBounds();
        
        // wait until html renders
        timer = setTimeout(function(){
            if(o.w === this.region.width() &&
               o.h === this.region.height()){

                if(this.container.hasClass("max-width") === false){
                    this.container.addClass("max-width");
                }else{
                    this.container.removeClass("max-width");
                }

                this.map.invalidateSize();
                this.map.fitBounds(bounds);

                triggerEvent.apply(this, [evt]);

            }
        }.bind(this), 100);
    };


    apex.plugins.mapbox.mapBoxMap = function(opts) {
        this.map = null;
        this.options = {};
        this.container = null;
        this.region = null;
        this.events = [];
        this.apexname = "MAPBOXREGION";
        this.init = function() {

            if ($.isPlainObject(options)) {
                this.options = $.extend(true, {}, this.options, options, opts);
            } else {
                throw "apex.plugins.mapBoxMap: Invalid options passed.";
            }

            if (this.options.mapRegionContainer === null) {
                throw "apex.plugins.mapBoxMap: mapRegionContainer is required.";
            }

            this.container = $("#" + this.options.mapRegionContainer);

            if (this.container.length !== 1) {
                throw "apex.plugins.mapBoxMap: Invalid region selector.";
            }

            if (this.options.mapRegionId === null) {
                throw "apex.plugins.mapBoxMap: mapRegionContainer is required.";
            }

            this.region = $("#" + this.options.mapRegionId);

            if (this.region.length !== 1) {
                throw "apex.plugins.mapBoxMap: Invalid region selector.";
            }



            this.container.addClass("mapbox-map");
            
            this.map = L.mapbox.map(this.container.get(0), 
                                    'mapbox.streets',
                                    {
                                        trackResize: true, 
                                        detectRetina: true
                                    });

            this.container.height(this.options.height);
            this.container.width(this.options.width);

            if (this.options.initalView.x &&
                this.options.initalView.y &&
                this.options.initalView.zoomLevel) {

                this.setView(
                    this.options.initalView.x,
                    this.options.initalView.y,
                    this.options.initalView.zoomLevel
                )
            }

            this.map.on("move"   , bboxChangeEvt.bind(   this, "mapboxmap-change-bbox."      + this.apexname));
            this.map.on("zoomend", zoomLlvChangeEvt.bind(this, "mapboxmap-change-zoomlevel." + this.apexname));
            this.region.on("click", 'span.js-maximizeButtonContainer', 
                           resizeMap.bind(this, "mapboxmap-maximize-region." + this.apexname));

            this.region.data("mapboxRegion", this);
            return this;
        }

        return this.init();
    }
    apex.plugins.mapbox.mapBoxMap.prototype = {
        /**
         * [setView -  API method, zoom to spec. position]
         * @param   Number  x          x cord.
         * @param   Number  y          y cord.
         * @param   Number  zoomLevel zoomLevel
         */
        setView: function setView(x, y, zoomLevel) {
            return this.map
                       .setView([x, y], zoomLevel);
        },
        /**
         * [zoomTo set/get zoomLevel]
         * @param   Number  zoomLevel
         * @return  Number  zoomLevel
         */
        zoomTo: function zoomTo(zoomLevel){
            if(zoomLevel){
                this.map.setZoom(zoomLevel);
            }

            return this.map.getZoom();
        },
        /**
         * [setBounds - zoom to spec. bounds]
         * @param L.bounds bbox     L.bounds - object
         * @param Number zoomLevel  zoomLevel - number
         */
        setBounds: function setBounds(bbox, zoomLevel) {
                this.map.fitBounds(bbox);
                if(this.map.zoomTo){
                    this.map.zoomTo(zoomLevel);
                }
            return this;
        },

        /**
         * [setGeoJSON - load geojson object on map]
         * @param Object  geoJson geoJson object
         * @param Boolean zoomTo  true/false to zoom on geometry bounds
         */
        setGeoJSON:function setGeoJSON(geoJson, zoomTo) {
            this.map.featureLayer.setGeoJSON(geoJson);
            if(zoomTo === true){
                this.setBounds(this.map.featureLayer.getBounds());
            }
            return this;
        }

    };

})(apex.jQuery);
