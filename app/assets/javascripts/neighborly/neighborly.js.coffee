#= require_self
#= require_tree .

window.Neighborly =
  configs:
    turbolinks: true
    pjax: false
    respond_with:
      'Create': 'New'
      'Update': 'Edit'

  modules: -> []

  initPage: ->
    unless NProgress is undefined
      NProgress.configure
        showSpinner: false
    unless window.Turbolinks is undefined
      $(document).bind "page:fetch", =>
        this.Loading.show()

      $(document).bind "page:restore", =>
        this.Loading.hide()

      $(document).bind "page:change", =>
        $(window).scrollTop(0)

        try
          FB.XFBML.parse()
        try
          twttr.widgets.load()

  init: ->
    $(document).foundation('reveal', {animation: 'fadeAndPop', animationSpeed: 100})
    $(document).foundation()
    this.flash.init()
    this.backstretch.init()

    $('.bs-affix').affix({
      offset: {
        top: 0
        bottom: ->
          return (this.bottom = $('footer').outerHeight(true))
      }
    })
    $('.side-nav').localScroll({offset: -180})

    $.pjax.defaults.scrollTo = false if $.pjax.defaults?
    $.pjax.defaults.timeout = false if $.pjax.defaults?

    $('nav.top-bar a').click ->
      this.blur()

    $('.button.disabled').click ->
      return false

    $('.top-bar .search-button').click ->
      if $('.discover-form-input').val() != ''
        $('form.discover-form').submit()
      else
        $('.discover-form-input').toggleClass('show').focus()

      return false

    # Disable zoom for iOS when clicking on inputs, selects and textareas
    $('input, select, textarea').focus ->
      $('meta[name=viewport]').attr('content', 'width=device-width,initial-scale=1,maximum-scale=1.0')
    $('input, select, textarea').blur ->
      $('meta[name=viewport]').attr('content', 'width=device-width,initial-scale=1,maximum-scale=10')

    if jQuery.browser.mobile
      Neighborly.TransformTabsToDropdown.init()

  Loading:
    show: ->
      $('#loading').addClass('show')
    hide: ->
      $('#loading').removeClass('show')

  flash:
    init: ->
      clearTimeout(this.flash_time_out)
      if $('.flash').length > 0
        this.flash_time_out = setTimeout(this.close, 5000)
        $('.flash .dismissible a.close').click(this.close)

    close: ->
      $('.flash .alert-box.dismissible').slideUp('slow')

  backstretch:
    init: ->
      has_image = -> $(header).data('image-url')?
      for header in $('header.hero:not(.no-image)') when has_image() then do (header) =>
        header = $(header)
        header.backstretch(header.data('image-url'), {fade: 'normal'})
