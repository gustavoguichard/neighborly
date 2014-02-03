Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Contributions = {} if Neighborly.Projects.Contributions is undefined

Neighborly.Projects.Contributions.Index =
  init: Backbone.View.extend _.extend(
    el: '.contributions-page'

    initialize: ->
      this.use_custom_append = true
      Neighborly.CustomTooltip()
      this.$loader = this.$('.contributions-loading img')
      this.$loaderDiv = this.$('.contributions-loading')
      this.$results = this.$('.list')
      this.path = this.$el.data('path')
      this.filter = { page: 2 }
      this.setupScroll()

      this.$masonry = this.masonry()
      this.$el.on 'scroll:success', (event, data) =>
        Neighborly.CustomTooltip()
        $data = $(data).filter('div')
        this.$('.list').append $data
        this.$('.list').masonry('appended', $data)

    masonry: ->
      this.$('.list').masonry ->
        itemSelector: '.contribution-wrapper'
        #columnWidth : 230


    , Neighborly.InfiniteScroll)

