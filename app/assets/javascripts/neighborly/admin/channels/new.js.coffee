Neighborly.Admin.Channels ?= {}
Neighborly.Admin.Channels ?= {}

Neighborly.Admin.Channels.New =
  init: Backbone.View.extend
    el: '.admin'

    initialize: ->
      this.$('.markdown-editor').markItUp(Neighborly.markdownSettings)


Neighborly.Admin.Channels.Edit =
  modules: -> [Neighborly.Admin.Channels.New]
