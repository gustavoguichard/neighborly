Neighborly.Users ?= {}

Neighborly.Users.Payments =
  modules: -> []
  init: Backbone.View.extend
    el: '.user-payments-content'

    initialize: ->
      $accounts = $(".account-method")

      for account in $accounts
        $account = $(account)
        if $account.data('path')
          $account.html('loading...')
          $.get($account.data('path')).success (data) =>
            this.$('.account-method').html('')
            $account.html data
            Initjs.initializePartial()
