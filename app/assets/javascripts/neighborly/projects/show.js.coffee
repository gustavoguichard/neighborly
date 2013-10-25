Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Show = Backbone.View.extend
  el: '.project-page'

  events:
    'click .scroll-to-top': 'scrollTop'

  initialize: ->
    $tabs = new Neighborly.Tabs()
    $rewards = new Neighborly.Rewards.Index()
    this.statusBar()

  statusBar: ->
    offset = $('.status-bar').offset().top
    $(window).scroll ->
      if $(document).scrollTop() > offset
        this.$('.status-bar').addClass('fixed')
      else
        this.$('.status-bar').removeClass('fixed')

  scrollTop: (event)->
    event.preventDefault()
    $(document).scrollTop(0)
