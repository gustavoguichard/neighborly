Neighborly.Projects ?= {}
Neighborly.Projects.Matches ?= {}

Neighborly.Projects.Matches.Edit =
  modules: -> [Neighborly.CustomTooltip]

  init: Backbone.View.extend
    el: '.edit-match-page'

    initialize: ->
      this.$('.payment-method-option-balanced-bankaccount').insertBefore(
        this.$('.payment-method-option-balanced-creditcard')
      )
      @payment_view = new Neighborly.Payment()
      @payment_view.togglePaymentFee()
