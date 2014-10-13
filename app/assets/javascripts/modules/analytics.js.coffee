$.ready ->
  $('.my-spot .facebook, #join-beta-modal .facebook').click ->
    mixpanel.track 'Shared spot using Facebook'

  $('.my-spot .twitter, #join-beta-modal .twitter').click ->
    mixpanel.track 'Shared spot using Twitter'
