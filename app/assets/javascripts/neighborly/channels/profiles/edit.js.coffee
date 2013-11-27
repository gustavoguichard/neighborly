Neighborly.Channels ?= {}
Neighborly.Channels.Profiles ?= {}

Neighborly.Channels.Profiles.Edit =
  init: Backbone.View.extend
    el: '.edit-channel-page'

    initialize: ->
      this.$('#profile_how_it_works').markItUp(Neighborly.markdownSettings)
