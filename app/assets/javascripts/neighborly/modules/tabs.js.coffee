Neighborly.Tabs = Backbone.View.extend
  el: 'nav.tabs'

  events:
    'click a': 'toggleSelected'

  initialize: (options)->
    return if this.$el.length is 0
    options = _.extend({ enable_pjax: true }, options)

    this.$target_container = $(this.el).data('target-container')

    if options.enable_pjax is true
      this.initPjax()

  toggleSelected: (event)->
    $target = $(event.currentTarget)
    unless $target.hasClass('selected')
      this.$('.selected').removeClass('selected')
      $target.addClass('selected')

  initPjax: ->
    $(this.el).pjax('a', this.$target_container)
    this.bindPjaxLoading()

  bindPjaxLoading: ->
    $(this.$target_container).on 'pjax:send', =>
      $(this.$target_container).addClass('loading-section')

    $(this.$target_container).on 'pjax:complete', =>
      $(this.$target_container).removeClass('loading-section')
      Initjs.initializePartial()
