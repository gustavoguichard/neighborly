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

    $.pjax.defaults.scrollTo = false if $.pjax.defaults?
    $.pjax.defaults.timeout = false if $.pjax.defaults?

    $('.button.disabled').click ->
      return false

    $('.top-bar .search-button').click ->
      if $('.discover-form-input').val() != ''
        $('form.discover-form').submit()
      else
        $('.discover-form-input').toggleClass('show').focus()

      return false

  Loading:
    show: ->
      $('#loading').addClass('show')
    hide: ->
      $('#loading').removeClass('show')

  flash:
    init: ->
      clearTimeout(this.flash_time_out)
      if $('.flash').length > 0
        this.flash_time_out = setTimeout(this.close, 5000) if $('.flash .alert-box.dismissible').length == $('.flash .alert-box').length
        $('.flash a.close').click(this.close)

    close: ->
      $('.flash .alert-box').fadeOut('fast')
      setTimeout (->
        $('.flash').slideUp('slow')
      ), 100

  backstretch:
    init: ->
      if $('header.hero').not('.no-image').data('image-url') != null && $('header.hero').not('.no-image').data('image-url') != ''
        $('header.hero').backstretch($('header.hero').data('image-url'), {fade: 'normal'})

