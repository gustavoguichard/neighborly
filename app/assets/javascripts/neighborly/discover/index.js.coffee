Neighborly.Discover = {} if Neighborly.Discover is undefined

Neighborly.Discover.Index =
  init: Backbone.View.extend
    el: '.discover-page'

    events:
      'click .tags a': 'toggleTag'
      'click .search .search-button': 'searchButton'

    initialize: ->
      that = this
      this.$target_container = this.$('section.content')
      this.$('.near-input, .category-input, .filter-input').change ->
        that.process()

      this.$('form.discover-form').submit (e)->
        e.preventDefault()
        that.process()

      this.bindPjaxLoading()

    searchButton: (e)->
      e.preventDefault()
      this.process()

    process: ->
      $filter = this.$('.filter-input')
      $near = this.$('.near-input')
      $category = this.$('.category-input')
      $tags = this.$('.tags a.selected')
      $search = this.$('.search-input')

      url = this.generateUrl($filter, $near, $category, $tags, $search)
      $.pjax({ url: url, container: this.$target_container })

    generateUrl: ($filter, $near, $category, $tags, $search)->
      url = this.$el.data('path')
      if $filter.val() != ''
        url += "/#{$filter.val().toLowerCase()}"

      if $near.val() != ''
        url += "/near/#{$near.val()}"

      if $category.val() != ''
        url += "/category/#{$category.val().toLowerCase()}"

      if $tags.length > 0
        tags = _.map $tags, (t) -> $(t).data('name')
        url += "/tags/#{tags.join()}"

      if $search.val() != ''
        url += "/search/#{$search.val()}"

      return url

    toggleTag: (event)->
      event.preventDefault()
      $target = $(event.currentTarget)
      $target.toggleClass('selected')
      this.process()

    bindPjaxLoading: ->
      that = this
      $(this.$target_container).on 'pjax:send', ->
        $(that.$target_container).addClass('loading-section')

      $(this.$target_container).on 'pjax:complete', ->
        $(that.$target_container).removeClass('loading-section')
        Initjs.initializePartial()
