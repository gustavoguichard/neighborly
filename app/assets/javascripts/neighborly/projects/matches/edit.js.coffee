Neighborly.Projects ?= {}
Neighborly.Projects.Matches ?= {}

Neighborly.Projects.Matches.Edit =
  modules: ->

  init: Backbone.View.extend
    el: '.create-match-page'

    initialize: ->
      @payment_view = new Neighborly.Payment()
