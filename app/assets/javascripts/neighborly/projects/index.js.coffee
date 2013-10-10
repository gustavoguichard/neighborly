Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Index = Backbone.View.extend
  el: '.home-page'

  events:
    'change .change-city': 'changeCity'

  initialize: ->


  changeCity: ->
    city = this.$('.change-city').val()
    url = "#{this.$('.change-city').data('projects-path')}?location=#{city}"

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
