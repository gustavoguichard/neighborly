Neighborly.Users = {} if Neighborly.Users is undefined

Neighborly.Users.modules =-> [Neighborly.Tabs]

Neighborly.Users.Edit =
  init: Backbone.View.extend
    el: '.user-edit-page'

    initialize: ->
      this.el.insertAdjacentHTML 'beforeend', '<div id="dropzone-preview-image"></div>'
      this.uploaders = []
      for uploader in $('.usr-upld-img')
        this.uploaders.push new Neighborly.Users.Edit.DragDropUploader { el: uploader }

  DragDropUploader: Backbone.View.extend
    events:
      'mouseenter': 'mouseEnter'
      'mouseleave': 'mouseLeave'

    # TODO: Uploader functionality
    initialize: ->
      _.bindAll this, 'onFileAdded', 'onUploadProgress', 'onUploadComplete', 'onUploadFail', 'mouseEnter', 'mouseLeave'
      this.action_url = this.$el.closest('form')[0].getAttribute("action")
      this.param_name = this.$el[0].dataset.param
      this.$image_previewer = this.$('.uploaded-image')
      this.initializeDropzone()

    initializeDropzone: ->
      this.dropzone = new Dropzone(this.el,
        url: this.action_url
        acceptedFiles: "image/*"
        headers: "X-CSRF-Token" : $('meta[name="csrf-token"]')[0].getAttribute 'content'
        paramName: "user[#{this.param_name}]"
        method: 'PUT'
        uploadMultiple: false
        previewsContainer: '#dropzone-preview-image'
      )
      this.dropzone.on "addedfile", this.onFileAdded
      this.dropzone.on "uploadprogress", this.onUploadProgress
      this.dropzone.on "success", this.onUploadComplete
      this.dropzone.on "error", this.onUploadFail

    onFileAdded: (file)->
      this.$('.info').text 'Drop an image here'
      this.$el.removeClass('upload-complete upload-fail').addClass 'upload-started'

    onUploadProgress: (file, progress)->
      this.$('.info').text 'Drop an image here'

    onUploadComplete: (file, response)->
      this.$('.info').text 'Drop an image here'
      this.$el.removeClass('upload-started').addClass 'upload-complete'
      this.$image_previewer.css 'background-image', "url(#{response[this.param_name]})"

    onUploadFail: (file, error)->
      this.$('.info').text error
      this.$el.removeClass('upload-started').addClass 'upload-fail'

    mouseEnter: (e)->
      this.$el.addClass 'dragging'

    mouseLeave: (e)->
      this.$el.removeClass 'dragging'