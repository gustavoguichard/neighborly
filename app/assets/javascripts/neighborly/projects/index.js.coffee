Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Index =
  init: Backbone.View.extend
    initialize: ->
      $('.home-page header').localScroll
        duration: 600
