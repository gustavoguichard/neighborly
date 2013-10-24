Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Show = Backbone.View.extend
  el: '.project-page'

  initialize: ->
    $tabs = new Neighborly.Tabs()
    $rewards = new Neighborly.Rewards.Index()

