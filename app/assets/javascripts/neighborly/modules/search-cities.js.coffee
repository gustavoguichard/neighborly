Neighborly.SearchCities = (searchInputSelctor, mapCanvasSelector) ->
  window.searchInputSelctor = searchInputSelctor
  window.mapCanvasSelector = mapCanvasSelector

  $.getScript('https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=places&callback=Neighborly.SearchCitiesInitialize')

  Neighborly.SearchCitiesInitialize = ->
    searchInputSelctor = '.search-cities-with-google'  if typeof searchInputSelctor is 'undefined'
    mapCanvasSelector = '.map-canvas'  if typeof mapCanvasSelector is 'undefined'
    searchInput = $(searchInputSelctor)[0]
    mapCanvas = $(mapCanvasSelector)[0]
    mapOptions =
      center: new google.maps.LatLng(37.09024, -95.712891)
      zoom: 3
      disableDefaultUI: true
      mapTypeId: google.maps.MapTypeId.ROADMAP

    autocomplete = new google.maps.places.Autocomplete(searchInput,
      types: ['(cities)']
      componentRestrictions:
        country: 'us'
    )
    map = new google.maps.Map(mapCanvas, mapOptions)
    marker = new google.maps.Marker(map: map)
    placeChanged = ->
      $(searchInput).removeClass 'error'
      place = autocomplete.getPlace()
      unless place.geometry

        # Inform the user that the place was not found and return.
        $(searchInput).addClass 'error'
        return

      # If the place has a geometry, then present it on a map.
      if place.geometry.viewport
        map.fitBounds place.geometry.viewport
      else
        map.setCenter place.geometry.location
        map.setZoom 17 # Why 17? Because it looks good.

      marker.setIcon (
        url: $('.pin-img').data('image-url')
        size: new google.maps.Size(71, 71)
        origin: new google.maps.Point(0, 0)
        anchor: new google.maps.Point(17, 34)
        scaledSize: new google.maps.Size(35, 35)
      )
      marker.setPosition place.geometry.location
      marker.setVisible true
      false

    initializer = ->
      autocomplete.bindTo 'bounds', map
      google.maps.event.addListener autocomplete, 'place_changed', placeChanged
      $(searchInput).keydown (event) ->
        if event.keyCode is 13
          event.preventDefault()
          false

      if $('.address-coordinates').data('longitude') isnt `undefined` and $('.address-coordinates').data('latitude') isnt `undefined`
        lat_lng = new google.maps.LatLng($('.address-coordinates').data('latitude'), $('.address-coordinates').data('longitude'))
        map.setCenter lat_lng
        map.setZoom 12
        marker.setIcon (
          url: $('.pin-img').data('url')
          size: new google.maps.Size(71, 71)
          origin: new google.maps.Point(0, 0)
          anchor: new google.maps.Point(17, 34)
          scaledSize: new google.maps.Size(35, 35)
        )
        marker.setPosition lat_lng
        marker.setVisible true

    initializer()
