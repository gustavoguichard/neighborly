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
          $.get($account.data('path')).success (data) =>
            $account.html data
            Initjs.initializePartial()

            $('.use-existing-item input:not(#payment_show_bank_existing)')
              .attr('disabled', '1')

            $('#payment_show_bank_existing').click()
