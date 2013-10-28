Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.modules =-> [Neighborly.Tabs, Neighborly.Rewards.Index, Neighborly.Projects.Show.StatusBar]

Neighborly.Projects.Show =
  init: Backbone.View.extend
    el: '.project-page'

    initialize: ->

  StatusBar: Backbone.View.extend
    el: '.project-page'

    events:
      'click .scroll-to-top': 'scrollTop'

    initialize: ->
      offset = this.$('.status-bar').offset().top
      $(window).scroll ->
        if $(document).scrollTop() > offset
          this.$('.status-bar').addClass('fixed')
        else
          this.$('.status-bar').removeClass('fixed')

    scrollTop: (event)->
      event.preventDefault()
      $(document).scrollTop(0)

