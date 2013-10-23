Neighborly.Rewards = {} if Neighborly.Rewards is undefined

Neighborly.Rewards.Index = Backbone.View.extend
  el: '.rewards'

  initialize: ->
    this.load()

  load: ->
    that = this
    $.ajax(
      url: $(that.el).data("rewards-path")
      success: (data) ->
        $(that.el).html data
    )
