Neighborly.Channels ?= {}
Neighborly.Channels.Profiles ?= {}

Neighborly.Channels.Profiles.Show =
  init: Backbone.View.extend
    el: '.channel-page'
    events:
      'click .see-more-toggle': 'toggleMoreSection'

    initialize: ->

    toggleMoreSection: (event)=>
      event.preventDefault()
      this.$('.header').toggleClass('expanded')
      this.$('.see-more-toggle span').toggleClass('hide')
