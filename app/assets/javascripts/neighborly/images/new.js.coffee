Neighborly.Images = {} if Neighborly.Images is undefined

Neighborly.Images.New =
  init: Backbone.View.extend
    el: '.new-image-page'

    initialize: ->
      if this.$('.use-simple-uploader').length > 0
        new this.SimpleUploader { el: '.new-image-page' }
      else
        new this.DragDropUploader { el: '.new-image-upload-dropzone' }

    SimpleUploader: Backbone.View.extend
      initialize: ->
        that = this
        this.$image_previewer = this.$('.uploaded-image')
        this.$uploaded_image_url = this.$('.uploaded-image-url')

        this.$('form').on 'ajax:complete', (xhr, response)->
          if response.status == '200'
            that.onUploadSuccess(response.responseText)
          else
            that.onUploadFail()

      onUploadSuccess: (responseText)->
        json = jQuery.parseJSON(responseText)
        this.$image_previewer.
          attr('src', json['image[file]']).
          addClass('upload-complete')

        this.$uploaded_image_url.val json['image[file]']

        this.$('.will-show').removeClass('hide')
        this.$('.will-hide').addClass('hide')
        this.$('.title').html('Upload complete!')
        this.$('.info').text ''

      onUploadFail: ->
        this.$('.info').html('Error uploading, try it again.')
        this.$image_previewer.addClass('upload-fail')


    DragDropUploader: Backbone.View.extend
      events:
        'mouseenter': 'mouseEnter'
        'mouseleave': 'mouseLeave'
        'click *': 'openFileChooser'

      initialize: ->
        _.bindAll this, 'onFileAdded', 'onUploadProgress', 'onUploadComplete', 'onUploadFail', 'mouseEnter', 'mouseLeave', 'openFileChooser'
        this.action_url = this.$el.closest('form')[0].getAttribute("action")
        this.param_name = this.$el.data('param')
        this.$image_previewer = this.$('.uploaded-image')
        this.$uploaded_image_url = $('.new-image-page .uploaded-image-url')
        this.$title = $('.new-image-page .title')
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
        this.$('.info').text ''
        this.$el.removeClass('upload-complete upload-fail').addClass 'upload-started'

      onUploadProgress: (file, progress)->
        this.$title.html 'Uploading...'

      onUploadComplete: (file, response)->
        this.$title.html 'Upload complete!'
        this.$el.removeClass('upload-started').addClass 'upload-complete'
        this.$image_previewer.attr 'src', response[this.param_name]
        this.$uploaded_image_url.val(response[this.param_name])
        $('.new-image-page .will-show').removeClass('hide')
        $('.new-image-page .will-hide').addClass('hide')

      onUploadFail: (file, error)->
        this.$('.info').text 'Error uploading, try it again. Click here to select the image again or just drag and drop it.'
        this.$el.removeClass('upload-started').addClass 'upload-fail'

      openFileChooser: (e)->
        this.$el.trigger 'click'

      mouseEnter: (e)->
        this.$el.addClass 'dragging'

      mouseLeave: (e)->
        this.$el.removeClass 'dragging'
