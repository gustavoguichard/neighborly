window.App.SearchCities = function(searchInputSelctor, mapCanvasSelector){

  if(typeof searchInputSelctor === "undefined"){
    searchInputSelctor = '.search-cities-with-google'
  }

  if(typeof mapCanvasSelector === "undefined"){
    mapCanvasSelector = '.map-canvas'
  }

  var searchInput = $(searchInputSelctor)[0];
  var mapCanvas = $(mapCanvasSelector)[0];

  var mapOptions = {
    center: new google.maps.LatLng(37.09024, -95.712891),
    zoom: 3,
    disableDefaultUI: true,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var autocomplete = new google.maps.places.Autocomplete(searchInput, {
     types: ['(cities)'],
     componentRestrictions: {country: "us"}
  });

  var map = new google.maps.Map(mapCanvas, mapOptions);

  var marker = new google.maps.Marker({ map: map });

  var placeChanged = function() {
    $(searchInput).removeClass('error');

    var place = autocomplete.getPlace();

    if (!place.geometry) {
      // Inform the user that the place was not found and return.
      $(searchInput).addClass('error');
      return;
    }

    // If the place has a geometry, then present it on a map.
    if (place.geometry.viewport) {
      map.fitBounds(place.geometry.viewport);
    } else {
      map.setCenter(place.geometry.location);
      map.setZoom(17);  // Why 17? Because it looks good.
    }
    marker.setIcon(/** @type {google.maps.Icon} */({
      url: $('.pin-img').data('url'),
      size: new google.maps.Size(71, 71),
      origin: new google.maps.Point(0, 0),
      anchor: new google.maps.Point(17, 34),
      scaledSize: new google.maps.Size(35, 35)
    }));
    marker.setPosition(place.geometry.location);
    marker.setVisible(true);
    return false;
  };

  var initializer = function(){
    autocomplete.bindTo('bounds', map);
    google.maps.event.addListener(autocomplete, 'place_changed', placeChanged);

    $(searchInput).keydown(function(event){
      if(event.keyCode == 13) {
        event.preventDefault();
        return false;
      }
    });


    if($('.address-coordinates').data('longitude') != undefined && $('.address-coordinates').data('latitude') != undefined){
      var lat_lng = new google.maps.LatLng($('.address-coordinates').data('latitude'), $('.address-coordinates').data('longitude'));
      map.setCenter(lat_lng);
      map.setZoom(12);
      marker.setIcon(({
        url: $('.pin-img').data('url'),
        size: new google.maps.Size(71, 71),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(17, 34),
        scaledSize: new google.maps.Size(35, 35)
      }));
      marker.setPosition(lat_lng);
      marker.setVisible(true);
    }

  };

  initializer();
}
