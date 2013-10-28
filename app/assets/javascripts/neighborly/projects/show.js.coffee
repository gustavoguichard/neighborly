Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.modules =-> [Neighborly.Tabs, Neighborly.Rewards.Index]

Neighborly.Projects.Show =
  init: Backbone.View.extend
    el: '.project-page'

    events:
      'click .scroll-to-top': 'scrollTop'

    initialize: ->
      this.statusBar()

    statusBar: ->
      offset = this.$('.status-bar').offset().top
      $(window).scroll ->
        if $(document).scrollTop() > offset
          this.$('.status-bar').addClass('fixed')
        else
          this.$('.status-bar').removeClass('fixed')

    scrollTop: (event)->
      event.preventDefault()
      $(document).scrollTop(0)
