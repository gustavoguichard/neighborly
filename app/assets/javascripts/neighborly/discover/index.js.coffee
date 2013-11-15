Neighborly.Discover = {} if Neighborly.Discover is undefined

Neighborly.Discover.Index =
  init: Backbone.View.extend
    el: '.discover-page'

    events:
      'click .tags a': 'toggleTag'
      'click .search .search-button': 'searchButton'
      'click .results-for a.remove-filter': 'removeFilter'

    initialize: ->
      _.bindAll(this, 'removeFilter')
      that = this
      this.$target_container = this.$('section.content')
      this.$('.near-input, .category-input, .filter-input').change ->
        that.process()

      this.$('form.discover-form').submit (e)->
        e.preventDefault()
        that.process()

      this.bindPjaxLoading()
      this.toggleDisplayResultsFor()

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
        this.addResultFor('filter', $filter.find(':selected').text())
      else
        this.removeResultFor('filter')

      if $near.val() != ''
        url += "/near/#{$near.val()}"
        this.addResultFor('near', $near.find(':selected').text())
      else
        this.removeResultFor('near')

      if $category.val() != ''
        url += "/category/#{$category.val().toLowerCase()}"
        this.addResultFor('category', $category.find(':selected').text())
      else
        this.removeResultFor('category')

      if $tags.length > 0
        tags = _.map $tags, (t) -> $(t).data('name')
        url += "/tags/#{tags.join()}"

      if $search.val() != '' && $search.val() != 'Search...'
        url += "/search/#{$search.val()}"
        this.addResultFor('search', $search.val())
      else
        this.removeResultFor('search')

      return url

    toggleTag: (event)->
      event.preventDefault()
      $target = $(event.currentTarget)

      if $target.hasClass('selected')
        this.removeResultFor('tags', $target.data('class'))
      else
        this.addResultFor('tags', $target.text(), $target.data('class'))

      $target.toggleClass('selected')
      this.process()

    bindPjaxLoading: ->
      that = this
      $(this.$target_container).on 'pjax:send', ->
        $(that.$target_container).addClass('loading-section')

      $(this.$target_container).on 'pjax:complete', ->
        $(that.$target_container).removeClass('loading-section')
        Initjs.initializePartial()

    addResultFor: (type, text, value)->
      filter = $('<div class="filter">')
      filter.append("#{text} &nbsp; | &nbsp; ")
      remove_button = $('<a class="remove-filter">').html('x').attr('data-filter-type', type)
      if type == 'tags'
        remove_button.attr('data-filter-value', value)

      this.removeResultFor(type, value)
      filter.append(remove_button)
      this.$('.results-for').append(filter)
      filter

    removeResultFor: (type, value)->
      if type == 'tags'
        this.$(".filters a.remove-filter[data-filter-type=#{type}][data-filter-value=#{value}]").parent('.filter').remove()
      else
        this.$(".filters a.remove-filter[data-filter-type=#{type}]").parent('.filter').remove()
      this.toggleDisplayResultsFor()

    toggleDisplayResultsFor: ->
      if this.$('.results-for .filter').size() > 0
        this.$('.results-for').show()
      else
        this.$('.results-for').hide()

    removeFilter: (e)->
      e.preventDefault()
      $target = $(e.currentTarget)
      type = $target.data('filter-type')

      if type == 'tags'
        this.$(".tags [data-class=#{$target.data('filter-value')}]").click()
        this.process()
      else
        if type == 'search'
          this.$(".#{type}-input").val('')
          this.process()
        else
          this.$(".#{type}-input").val('').trigger('change', true)

        this.removeResultFor(type)
