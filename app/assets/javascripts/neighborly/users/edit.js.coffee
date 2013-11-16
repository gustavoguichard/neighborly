Neighborly.Users = {} if Neighborly.Users is undefined

Neighborly.Users.modules =-> [Neighborly.Tabs]

Neighborly.Users.Edit =
  init: Backbone.View.extend
    el: '.user-edit-page'

    initialize: ->
      @uploaders = []
      for uploader in $('.usr-upld-img')
        @uploaders.push new Neighborly.Users.Edit.DragDropUploader { el: uploader }

  DragDropUploader: Backbone.View.extend
    events:
      'mouseenter': 'mouseEnter'
      'mouseleave': 'mouseLeave'

    # TODO: Uploader functionality
    initialize: ->
      this.action_url = @$el.closest('form')[0].getAttribute("action")
      this.initializeDropzone()

    initializeDropzone: ->
      this.$el.dropzone
        url: this.action_url
        acceptedFiles: "image/*"
        headers: "X-CSRF-Token" : $('meta[name="csrf-token"]')[0].getAttribute 'content'
        paramName: 'user[hero_image]'
        method: 'PUT'


    mouseEnter: (e)->
      $(e.currentTarget).addClass 'dragging'

    mouseLeave: (e)->
      $(e.currentTarget).removeClass 'dragging'