Neighborly.Static ?= {}

Neighborly.Static.About =
  init: ->
    $.getScript('https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&callback=Neighborly.AboutPageMapInitialize')

Neighborly.AboutPageMapInitialize = ->
  MY_MAPTYPE_ID = 'custom_style'

  locations = [
      ['San Francisco, CA', 37.783300, -122.416700],
      ['Kansas City, MO', 39.099700, -94.578300]
    ]

  mapCanvasSelector = '.map-canvas' if typeof mapCanvasSelector is 'undefined'
  mapCanvas = $(mapCanvasSelector)[0]

  map = new google.maps.Map(mapCanvas,
    center: new google.maps.LatLng(37.783300, -122.416700)
    mapTypeControlOptions: {
      mapTypeIds: [google.maps.MapTypeId.TERRAIN, MY_MAPTYPE_ID]
    }
    mapTypeId: MY_MAPTYPE_ID
    scrollwheel: false
    zoomControlOptions:
      position: google.maps.ControlPosition.LEFT_BOTTOM
    disableDefaultUI: true
  )
  infowindow = new google.maps.InfoWindow(maxWidth: 160)
  marker = undefined
  markers = new Array()
  i = 0

  while i < locations.length
    marker = new google.maps.Marker(
      position: new google.maps.LatLng(locations[i][1], locations[i][2])
      map: map
      icon: $(mapCanvasSelector).data('pin-url')
    )
    markers.push marker
    i++


    bounds = new google.maps.LatLngBounds()
    $.each markers, (index, marker) ->
      bounds.extend marker.position
      return

    map.fitBounds bounds

  featureOpts = [
    {
      stylers: [
        { hue: '#27B18B' },
        { visibility: 'simplified' },
        { gamma: 0.7 },
        { weight: 0.5 }
      ]
    },
    {
      elementType: 'labels',
      stylers: [
        { visibility: 'off' }
      ]
    },{
      featureType: 'administrative.locality',
      elementType: 'labels',
      stylers: [
        { visibility: 'simplified' },
        { color: '#909090' }
      ]
    },

    {
      featureType: 'water',
      stylers: [
        { color: '#f0f0f0' }
      ]
    }
  ]

  styledMapOptions = {
    name: 'Custom Style'
  }

  customMapType = new google.maps.StyledMapType(featureOpts, styledMapOptions)

  map.mapTypes.set(MY_MAPTYPE_ID, customMapType)
  historicalOverlay = new google.maps.GroundOverlay($(mapCanvasSelector).data('overlay-image-url'), bounds)
  historicalOverlay.setMap(map)
