Neighborly.Tabs = Backbone.View.extend
  el: 'nav.tabs'

  events:
    'click a': 'toggleSelected'

  initialize: (options)->
    options = _.extend({ enable_pjax: true }, options)

    $.pjax.defaults.scrollTo = false if $.pjax.defaults?
    this.$target_container = $(this.el).data('target-container')

    if options.enable_pjax is true
      this.initPjax()

  toggleSelected: (event)->
    $(this.el).find('.selected').removeClass('selected')
    $(event.currentTarget).addClass('selected')

  initPjax: ->
    $(this.el).pjax('a', this.$target_container)
    this.bindPjaxLoading()

  bindPjaxLoading: ->
    that = this
    $(this.$target_container).on 'pjax:send', ->
      $(that.$target_container).addClass('loading-section')

    $(this.$target_container).on 'pjax:complete', ->
      $(that.$target_container).removeClass('loading-section')
      Initjs.initializePartial()
