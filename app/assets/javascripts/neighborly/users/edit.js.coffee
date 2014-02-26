Neighborly.Users = {} if Neighborly.Users is undefined

Neighborly.Users.modules =-> [Neighborly.Tabs]

Neighborly.Users.Edit =
  modules: -> [Neighborly.SearchCities]
  init: Backbone.View.extend
    el: '.user-edit-page'
    events:
      'change .user_profile_type .radio_buttons': 'changedProfile'

    initialize: ->
      _.bindAll this, 'changedProfile'
      this.$('#user_channel_attributes_how_it_works, #user_channel_attributes_submit_your_project_text').markItUp(Neighborly.markdownSettings) if this.$('#user_channel_attributes_how_it_works').length > 0
      if window.File && window.FileReader && window.FileList && window.Blob
        this.prepareToDropzone()
        this.uploaders = []
        for uploader in $('.usr-upld-img')
          this.uploaders.push new Neighborly.Users.Edit.DragDropUploader { el: uploader }

    prepareToDropzone: ->
      this.el.insertAdjacentHTML 'beforeend', '<div id="dropzone-preview-image"></div>'
      this.$('input.fallback[type=file]').closest('.input.file').remove()

    changedProfile: (e)->
      value = e.target.value
      for profile in this.$('.profile-type-images')
        if profile.id == "#{value}-images"
          $(profile).show()
        else
          $(profile).hide()

      for profile in this.$('.profile-type-name')
        if profile.id == "#{value}-name"
          $(profile).show()
        else
          $(profile).hide()

  DragDropUploader: Backbone.View.extend
    events:
      'mouseenter': 'mouseEnter'
      'mouseleave': 'mouseLeave'
      'click *': 'openFileChooser'

    # TODO: Uploader functionality
    initialize: ->
      _.bindAll this, 'onFileAdded', 'onUploadProgress', 'onUploadComplete', 'onUploadFail', 'mouseEnter', 'mouseLeave', 'openFileChooser'
      this.action_url = this.$el.closest('form')[0].getAttribute("action")
      this.param_name = this.$el[0].dataset.param
      this.$image_previewer = this.$('.uploaded-image')
      this.initializeDropzone()
      this.listenDropzoneEvents()

    initializeDropzone: ->
      this.dropzone = new Dropzone(this.el,
        url: this.action_url
        acceptedFiles: "image/*"
        headers: "X-CSRF-Token" : $('meta[name="csrf-token"]')[0].getAttribute 'content'
        paramName: "user[#{this.param_name}]"
        params: this.defineParams()
        method: 'PUT'
        uploadMultiple: false
        previewsContainer: '#dropzone-preview-image'
      )

    defineParams: ->
      if $('#user_profile_type_organization').is(':checked') && $('#user_organization_attributes_id').length > 0
        { 'user[organization_attributes][id]': $('#user_organization_attributes_id').val() }

    listenDropzoneEvents: ->
      if this.dropzone?
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
      this.$image_previewer.attr 'src', response[this.param_name]

    onUploadFail: (file, error)->
      this.$('.info').text error
      this.$el.removeClass('upload-started').addClass 'upload-fail'

    openFileChooser: (e)->
      this.$el.trigger 'click'

    mouseEnter: (e)->
      this.$el.addClass 'dragging'

    mouseLeave: (e)->
      this.$el.removeClass 'dragging'
