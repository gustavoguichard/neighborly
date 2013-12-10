Neighborly.InfiniteScroll =
  setupScroll: ->
    _.bindAll(this, 'onScroll', 'onSuccess')
    this.$window().scroll(this.onScroll)

  fetchPage: ->
    # the isLoaderDivVisible check if the div is already in the view pane to load more content
    # the $loader.is(:visible) is here to avoid trigerring two concurrent fetchPage calls
    if this.isLoaderDivVisible() and not this.$loader.is(":visible") and not this.EOF
      this.$loader.show()
      $.get(this.path, this.filter).success this.onSuccess
      this.filter.page += 1

  onSuccess: (data) ->
    this.EOF = true  if $.trim(data) is ""
    this.$results.append data unless this.use_custom_append? && this.use_custom_append == true
    this.$loader.hide()
    this.$el.trigger "scroll:success", data

  $window: ->
    $(window)

  isLoaderDivVisible: ->
    this.$loaderDiv.is(":visible") and this.$window().scrollTop() + this.$window().height() > this.$loaderDiv.offset().top

  onScroll: (event) ->
    this.fetchPage()
