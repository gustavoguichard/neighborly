Neighborly.Static ?= {}

Neighborly.Static.Learn =
  init: Backbone.View.extend
    el: '.learn-page'

    initialize: ->
      if window.innerWidth < 1000
        $('.main-section').localScroll duration: 600
      else
        $('.expand-section').click this.expand_section

    expand_section: (event) ->
      event.preventDefault()
      $(this).parents('.main-section').find('.section-content').slideToggle 500, =>
        elem = $(this).find('.expansion-btn')
        current_text = elem.text()
        elem.text(elem.attr('data-alternative-text'))
        elem.attr('data-alternative-text', current_text)
        $('.expand-section-icon').toggleClass('icon-fa-chevron-down').
          toggleClass('icon-fa-chevron-up')
