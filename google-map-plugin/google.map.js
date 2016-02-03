
function googleMap(pRegionId) {
    var $ = apex.jQuery, region = $("#" + pRegionId);

    if(region.length !== 1) {
      throw "googleMap: Invalid region selector";
    }

    region.append($("<div>",{"id":"map","class":"google-map"}));

    googleMapPromise.done(function(){
        googleApi.adapter.util.Map = new google.maps.Map(document.getElementById('map'),
          {
            center: {lat: 45.6514661, lng: 15.674715},
            zoom: 8
          }
        );
      }
    );
}
