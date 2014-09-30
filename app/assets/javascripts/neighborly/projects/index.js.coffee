Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Index =
  init: ->(
    initialize: ->
      $('.features .list a').on 'mouseover', this.changeScreen
      $('.features .list a').on 'click', this.changeScreen

    changeScreen: (event)->
      event.preventDefault()
      $('.features .list a').removeClass('active')
      $(event.currentTarget).addClass('active')
      classToShow = $(event.currentTarget).data('class-to-show')
      $('.features .images img').hide()
      $(".features .images .#{classToShow}").show()

  ).initialize()

