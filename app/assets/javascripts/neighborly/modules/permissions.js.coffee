# Listens and respond properly clicks in anchors to unauthorized destinations.
#
# Using:
# Add a data-hyperlink-permission attribute
# to an anchor element with "false" as value.
Neighborly.Permissions = ->
  listenForUnauthorizedAccesses = ->
    $('[data-hyperlink-permission="false"]').click (event) ->
      event.preventDefault()
      openModal()
      trackClick(this)

  openModal = ->
    $('.not-authorized-modal')
      .foundation('reveal', opened: ->
        $(this).find('#user_email').focus()
      )
      .foundation('reveal', 'open')

  trackClick = (element) ->
    event_name = $(element).data('name')
    if event_name?
      mixpanel.track(event_name)

  listenForUnauthorizedAccesses()
