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
    that = this
    unless window.Turbolinks is undefined
      $(document).bind "page:fetch", ->
        that.Loading.show()

      $(document).bind "page:restore", ->
        that.Loading.hide()

      $(document).bind "page:change", ->
        $(window).scrollTop(0)

        try
          FB.XFBML.parse()
        try
          twttr.widgets.load()

  init: ->
    $(document).foundation('reveal', {animation: 'fadeAndPop', animationSpeed: 100})
    $(document).foundation()

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
      $('#loading #back-overlay, #loading #front-overlay').fadeIn(2)
    hide: ->
      $('#loading #back-overlay, #loading #front-overlay').hide()
