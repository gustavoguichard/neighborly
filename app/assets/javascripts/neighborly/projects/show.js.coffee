Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.modules =-> [Neighborly.Tabs, Neighborly.Rewards.Index, Neighborly.Projects.Show.StatusBar, Neighborly.Projects.Show.AskQuestion]


Neighborly.Projects.Show =
  init: Backbone.View.extend
    el: '.project-page'

    initialize: ->

  StatusBar: Backbone.View.extend
    el: '.project-page'

    initialize: ->
      return if this.$el.length is 0
      offset = this.$('.page-main-content').offset()
      offset = offset.top if offset?
      $(window).unbind('scroll')
      $(window).scroll ->
        if $(document).scrollTop() > offset
          this.$('.status-bar').addClass('show')
        else
          this.$('.status-bar').removeClass('show')

  AskQuestion: ->
    if window.location.hash == '#open-new-user-question-modal'
      $('a[data-reveal-id=ask-a-question]').trigger('click')
