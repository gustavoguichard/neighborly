Neighborly.Map = (mapCanvasSelector) ->
  window.mapCanvasSelector = mapCanvasSelector

  $.getScript('https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&callback=Neighborly.MapInitialize')

  Neighborly.MapInitialize = ->
    mapCanvasSelector = '.map-canvas' if typeof mapCanvasSelector is 'undefined'
    mapCanvas = $(mapCanvasSelector)[0]
    mapOptions =
      zoom: 11
      center: new google.maps.LatLng($('.address-coordinates').data('latitude'), $('.address-coordinates').data('longitude'))
      disableDefaultUI: true
    map = new google.maps.Map(mapCanvas, mapOptions)
