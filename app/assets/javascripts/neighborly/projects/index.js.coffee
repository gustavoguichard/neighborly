Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Index =
  init: Backbone.View.extend
    initialize: ->
      $('.hero .expand-section').on 'click', (event)->
        event.preventDefault()
        $target = $(event.currentTarget)

        current_text = $target.text()
        $target.text($target.attr('data-alternative-text'))
        $target.attr('data-alternative-text', current_text)

        $('.hero .expand-section-content').slideToggle
          progress: ->
            $('.hero').backstretch('resize')
          start: ->
            if $(window).width() >= 1000
              if $('.invest-box').css('margin-top') == '20px'
                $('.invest-box').animate({'margin-top': '-9.375em'})
              else
                $('.invest-box').animate({'margin-top': '20px'})

      $('.sign-up-with-facebook').click (event)->
        event.preventDefault()
        value = $('.investment-prospect-value').val()
        $target = $(event.currentTarget)

        location.href = "#{$target.attr('href')}&investment_prospect_value=#{value}"
