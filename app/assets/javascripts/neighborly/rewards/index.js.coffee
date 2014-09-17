Neighborly.Rewards = {} if Neighborly.Rewards is undefined

Neighborly.Rewards.Index = Backbone.View.extend
  el: '.rewards'

  events:
    'click .add-reward a': 'loadForm'
    'click .reward a.edit': 'loadForm'
    'click .reward a.cancel': 'cancel'
    'click .reward.clickable': 'newProjectContribution'

  initialize: ->
    return if this.$el.length is 0
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
        items: '.sortable'
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

  loadForm: (event) ->
    event.preventDefault()
    $target = this.$(event.currentTarget)
    $element = this.$($target.data('element'))
    $element.parents('.reward').addClass('editing')
    this.$rewards.find('.form-content').html('')

    $.ajax(
      url: $target.data('path')

      beforeSend: ->
        $element.find('.loading').show()

      success: (data) ->
        $element.find('.form-content').html(data).fadeIn('fast')
        $element.find('.loading').hide()

      error: ->
        $element.find('.loading').hide()
        $element.find('.form-content').hide()
    )

  cancel: (event)->
    event.preventDefault()
    $(event.currentTarget).parents('.hide').fadeOut('fast').parents('.editing').removeClass('editing')

  newProjectContribution: (event)->
    $target = $(event.target)
    return if $target.hasClass('edit') || $target.hasClass('cancel') || $target.hasClass('btn-contact') || $target.hasClass('editing') || $target.parents('.reward').hasClass('editing')
    url = $target.parents('.reward').data('new-project-contribution-path')
    if window.Turbolinks?
      window.Turbolinks.visit(url)
    else
      window.location.href = url
