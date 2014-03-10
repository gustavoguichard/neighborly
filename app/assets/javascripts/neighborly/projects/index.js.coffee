Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Index = Backbone.View.extend
  el: '.home-page'

  initialize: ->
    $('.locations-dropdown a').click(this.changeCity)

  changeCity: (event)->
    event.preventDefault()
    $el = $(event.currentTarget)
    url = $el.attr('href')
    $('a.change-city').html($el.html())
    $el.parents('[data-dropdown-content]').foundation('dropdown', 'close', $el.parents('[data-dropdown-content]'))

    $.ajax(
      url: url

      beforeSend: ->
        $('section.near .content').addClass('loading-section')

      success: (data) ->
        $('section.near .content').html data
        $('section.near .content').removeClass('loading-section')

      error: ->
        $('section.near .content').removeClass('loading-section')
    )
