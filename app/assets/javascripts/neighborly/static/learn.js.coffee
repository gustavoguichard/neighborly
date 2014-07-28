Neighborly.Static ?= {}

Neighborly.Static.Learn =
  init: Backbone.View.extend
    el: '.learn-page'

    initialize: ->
      $('.expand-section').click (event) ->
        that = this
        event.preventDefault()
        $(this).parents('.main-section').find('.section-content').slideToggle 500, ->
          elem = $(that).find('.expansion-btn')
          current_text = elem.text()
          elem.text(elem.attr('data-alternative-text'))
          elem.attr('data-alternative-text', current_text)
          $('.expand-section-icon').toggleClass('icon-fa-chevron-down').
            toggleClass('icon-fa-chevron-up')
