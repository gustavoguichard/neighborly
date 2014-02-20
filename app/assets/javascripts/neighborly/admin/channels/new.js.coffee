Neighborly.Admin.Channels ?= {}
Neighborly.Admin.Channels ?= {}

Neighborly.Admin.Channels.New =
  init: Backbone.View.extend
    el: '.admin'

    initialize: ->
      this.$('#channel_how_it_works, #channel_submit_your_project_text').markItUp(Neighborly.markdownSettings)


Neighborly.Admin.Channels.Edit =
  modules: -> [Neighborly.Admin.Channels.New]
