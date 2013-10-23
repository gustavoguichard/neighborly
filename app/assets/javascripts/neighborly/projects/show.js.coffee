Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Show = Backbone.View.extend
  el: '.project-page'

  initialize: ->
    $rewards = new Neighborly.Rewards.Index()
