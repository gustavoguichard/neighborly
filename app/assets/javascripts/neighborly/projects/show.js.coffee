Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Show = Backbone.View.extend
  el: '.project-page'

  initialize: ->
    $rewards = new this.Rewards()
    $rewards.load()


  Rewards: Backbone.View.extend
    el: '.rewards'

    initialize: ->

    load: ->
      that = this
      $.get($(that.el).data("rewards-path")).success (data) ->
        $(that.el).html(data)


