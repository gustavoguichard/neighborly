Neighborly.Static ?= {}

Neighborly.Static.Learn =
  init: Backbone.View.extend
    el: '.learn-page'

    initialize: ->
      $('.expand-section').click (event) ->
        event.preventDefault()
        $(this).parents('.main-section').find('.section-content').toggleClass('section-content-expanded', 500)
