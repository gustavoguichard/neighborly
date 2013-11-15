Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Backers = {} if Neighborly.Projects.Backers is undefined

Neighborly.Projects.Backers.Index =
  init: Backbone.View.extend _.extend(
    el: '.backers-page'

    initialize: ->
      Neighborly.CustomTooltip()
      this.$loader = this.$('.backers-loading img')
      this.$loaderDiv = this.$('.backers-loading')
      this.$results = this.$('.list')
      this.path = this.$el.data('path')
      this.filter = { page: 2 }
      this.setupScroll()
      this.$el.on 'scroll:success', Neighborly.CustomTooltip

    , Neighborly.InfiniteScroll)

