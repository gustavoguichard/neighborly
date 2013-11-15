Neighborly.Users = {} if Neighborly.Users is undefined

Neighborly.Users.modules =-> [Neighborly.Tabs]

Neighborly.Users.Edit =
  init: Backbone.View.extend
    el: '.user-edit-page'

    initialize: ->
      for uploader in $('.usr-upld-img')
        new Neighborly.Users.Edit.DragDropUploader { el: uploader }

  DragDropUploader: Backbone.View.extend
    events:
      'mouseenter': 'mouseEnter'
      'mouseleave': 'mouseLeave'

    # TODO: Uploader functionality
    initialize: ->

    mouseEnter: (e)->
      $(e.currentTarget).addClass 'dragging'

    mouseLeave: (e)->
      $(e.currentTarget).removeClass 'dragging'