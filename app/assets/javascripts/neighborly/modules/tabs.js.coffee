Neighborly.Tabs = Backbone.View.extend
  el: 'nav.tabs'

  events:
    'click a': 'toggleSelected'

  initialize: (options)->
    unless this.$el.find('[data-hyperlink-permission="true"]').length
      return

    options = _.extend({ enable_pjax: true }, options)

    this.$target_container = $(this.el).data('target-container')

    if options.enable_pjax
      this.initPjax()

  toggleSelected: (event)->
    $target = $(event.currentTarget)
    unless $target.hasClass('selected') || ($target.attr('data-hyperlink-permission') == 'false')
      this.$('.selected').removeClass('selected')
      $target.addClass('selected')

  initPjax: ->
    $(this.el).pjax('a[data-hyperlink-permission="true"]', this.$target_container)
    this.bindPjaxLoading()

  bindPjaxLoading: ->
    $(this.$target_container).on 'pjax:send', =>
      $(this.$target_container).addClass('loading-section')

    $(this.$target_container).on 'pjax:complete', =>
      $(this.$target_container).removeClass('loading-section')
      Initjs.initializePartial()
