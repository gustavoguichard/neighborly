$.ready ->
  $('.my-spot .facebook').click ->
    mixpanel.track 'Shared spot using Facebook'

  $('.my-spot .twitter').click ->
    mixpanel.track 'Shared spot using Twitter'
