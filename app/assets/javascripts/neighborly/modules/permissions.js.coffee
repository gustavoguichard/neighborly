# Listens and respond properly clicks in anchors to unauthorized destinations.
#
# Using:
# Add a data-hyperlink-permission attribute
# to an anchor element with "false" as value.
Neighborly.Permissions = ->
  listen_for_unauthorized_accesses = ->
    $('[data-hyperlink-permission="false"]').click (event) ->
      event.preventDefault()
      open_modal()
      track_click(this)

  open_modal = ->
    $('#sign-up-modal')
      .foundation('reveal', opened: ->
        $(this).find('#user_email').focus()
      )
      .foundation('reveal', 'open')

  track_click = (element) ->
    event_name = $(element).data('name')
    if event_name?
      console.log "tracked #{event_name}!"

  listen_for_unauthorized_accesses()
