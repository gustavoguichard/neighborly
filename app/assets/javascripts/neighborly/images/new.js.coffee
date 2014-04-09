Neighborly.Images = {} if Neighborly.Images is undefined

Neighborly.Images.New =
  init: Backbone.View.extend
    el: '.new-image-page'

    initialize: ->
      dropzone = new this.DragDropUploader { el: '.new-image-upload-dropzone' }

    DragDropUploader: Backbone.View.extend
      events:
        'mouseenter': 'mouseEnter'
        'mouseleave': 'mouseLeave'
        'click *': 'openFileChooser'

      # TODO: Uploader functionality
      initialize: ->
        _.bindAll this, 'onFileAdded', 'onUploadProgress', 'onUploadComplete', 'onUploadFail', 'mouseEnter', 'mouseLeave', 'openFileChooser'
        this.action_url = this.$el.closest('form')[0].getAttribute("action")
        this.param_name = this.$el.data('param')
        this.$image_previewer = this.$('.uploaded-image')
        this.$uploaded_image_url = $('.uploaded-image-url')
        this.initializeDropzone()
        this.listenDropzoneEvents()

      initializeDropzone: ->
        this.dropzone = new Dropzone(this.el,
          url: this.action_url
          acceptedFiles: "image/*"
          headers: "X-CSRF-Token" : $('meta[name="csrf-token"]')[0].getAttribute 'content'
          paramName: this.param_name
          params: ''
          method: 'POST'
          uploadMultiple: false
        )

      listenDropzoneEvents: ->
        if this.dropzone?
          this.dropzone.on "addedfile", this.onFileAdded
          this.dropzone.on "uploadprogress", this.onUploadProgress
          this.dropzone.on "success", this.onUploadComplete
          this.dropzone.on "error", this.onUploadFail

      onFileAdded: (file)->
        this.$('.info').text 'Sorry, something went wrong, try it again.'
        this.$el.removeClass('upload-complete upload-fail').addClass 'upload-started'

      onUploadProgress: (file, progress)->
        this.$('.info').text 'Uploading...'

      onUploadComplete: (file, response)->
        this.$('.info').text 'Upload complete!'
        this.$el.removeClass('upload-started').addClass 'upload-complete'
        this.$image_previewer.attr 'src', response[this.param_name]
        this.$uploaded_image_url.val(response[this.param_name])

      onUploadFail: (file, error)->
        this.$('.info').text error
        this.$el.removeClass('upload-started').addClass 'upload-fail'

      openFileChooser: (e)->
        this.$el.trigger 'click'

      mouseEnter: (e)->
        this.$el.addClass 'dragging'

      mouseLeave: (e)->
        this.$el.removeClass 'dragging'
