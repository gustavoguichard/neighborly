Neighborly.Rewards = {} if Neighborly.Rewards is undefined

Neighborly.Rewards.Index = Backbone.View.extend
  el: '.rewards'

  initialize: ->
    this.$rewards = $(this.el)
    this.load()
    this.sortable()

  load: ->
    that = this
    $.ajax(
      url: that.$rewards.data("rewards-path")
      success: (data) ->
        $(that.el).html data
    )

  sortable: ->
    that = this
    if this.$rewards.data("can-update") is true
      this.$rewards.sortable
        axis: "y"
        placeholder: "sortable-highlight"
        start: (e, ui) ->
          ui.placeholder.height ui.item.height()

        stop: (e, ui) ->
          ui.item.effect "highlight", {}, 1000

        update: (e, ui) ->
          csrfToken = undefined
          position = undefined
          position = that.$rewards.find('.sortable').index(ui.item)
          csrfToken = $("meta[name='csrf-token']").attr("content")
          $.ajax
            type: "POST"
            url: ui.item.data("update-path")
            dataType: "json"
            headers:
              "X-CSRF-Token": csrfToken

            data:
              reward:
                row_order_position: position

