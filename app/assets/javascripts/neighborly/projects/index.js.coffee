Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Index =
  init: ->(
    initialize: ->
      $('.features .list a').on 'mouseover', this.changeScreen
      $('.features .list a').on 'click', this.changeScreen
      $bbp = $('.built-by-people')
      animationOffset = -100
      $(window).on 'scroll', ->
        if $(window).scrollTop() >= ($bbp.offset().top + animationOffset)
          $bbp.removeClass('problem').addClass('solution') if $bbp.hasClass('problem')
        else
          $bbp.removeClass('solution').addClass('problem') if $bbp.hasClass('solution')

    changeScreen: (event)->
      event.preventDefault()
      $('.features .list a').removeClass('active')
      $(event.currentTarget).addClass('active')
      classToShow = $(event.currentTarget).data('class-to-show')
      $('.features .images img').hide()
      $(".features .images .#{classToShow}").show()

  ).initialize()
