/**
 * [created by isabolic sabolic.ivan@gmail.com]
 */
(function($) {
    var options = {
        mapRegionId: null,
        mapName: null,
        width: null,
        height: 300,
        initalView: {
            x:null,
            y:null,
            zoomLevel:null
        }
    };

    var triggerEvent =  function(evt, evtData){
        this.container.trigger(evt, [evtData]);
    };
    
    var bboxChangeEvt = function(evt){
        var bbox     = this.map.getBounds(),
            bboxJson = {
                "west" : bbox.getWest(), 
                "south": bbox.getSouth(),
                "east" : bbox.getEast(), 
                "north": bbox.getNorth(),
                "string": "BBOX(" + this.map.getBounds().toBBoxString() + ")"
            }

        triggerEvent.apply(this, [evt, bboxJson]);
    };

    var zoomLlvChangeEvt = function(evt){
        var lvl = {
            "zoomLevel": this.map.getZoom()
        }
        triggerEvent.apply(this, [evt, lvl]);
    };
    

    apex.plugins.mapBoxMap = function(opts) {
        this.map = null;
        this.options = {};
        this.container = null;
        this.events = [];
        this.apexname = "MAPBOXREGION";
        this.init = function() {

            if ($.isPlainObject(options)) {
                this.options = $.extend(true, {}, this.options, options, opts);
            } else {
                throw "apex.plugins.mapBoxMap: Invalid options passed.";
            }

            if (this.options.mapRegionId === null) {
                throw "apex.plugins.mapBoxMap: mapRegionId is required.";
            }

            this.container = $("#" + this.options.mapRegionId);

            if (this.container.length !== 1) {
                throw "apex.plugins.mapBoxMap: Invalid region selector.";
            }

            this.container.addClass("mapbox-map");
            this.map = L.mapbox.map(this.container.get(0), 'mapbox.streets');
            this.container.height(this.options.height);
            this.container.width(this.options.width);

            if( this.options.initalView.x && 
                this.options.initalView.y && 
                this.options.initalView.zoomLevel){
                
                this.zoomTo(
                    this.options.initalView.x, 
                    this.options.initalView.y, 
                    this.options.initalView.zoomLevel
                )
            }

            this.map.on("move"   , bboxChangeEvt.bind(this, "mapboxmap-change-bbox." + this.apexname));
            this.map.on("zoomend", zoomLlvChangeEvt.bind(this, "mapboxmap-change-zoomlevel." + this.apexname));

            return this;
        }

        return this.init();
    }
    apex.plugins.mapBoxMap.prototype = {
        zoomTo: function zoomTo(x,y, zoomLevel) {
            this.map
                .setView([x,y],zoomLevel);
        }
    };

})(apex.jQuery);
