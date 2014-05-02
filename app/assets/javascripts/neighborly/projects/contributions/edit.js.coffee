Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Contributions = {} if Neighborly.Projects.Contributions is undefined

Neighborly.Projects.Contributions.Edit =
  modules: -> [Neighborly.CustomTooltip]
  init: Backbone.View.extend
    el: '.create-contribution-page'

    events:
      'click .faqs a': 'openFaqText'

    initialize: ->
      @payment_view = new Neighborly.Payment()
      this.$('#pay_payment_fees').on 'change', this.togglePaymentFee
      this.togglePaymentFee()

    openFaqText: (e)->
      e.preventDefault()
      $(e.currentTarget).parent().find('p').toggleClass('hide')

    togglePaymentFee: =>
      $input = $('.create-contribution-page header .total-value input')
      $target = this.$('.methods input:checked')
      if $('.create-contribution-page #pay_payment_fees').is(':checked')
        value = $($target).data('value-with-fees')
        $('[data-pay-payment-fee]').val('1')
      else
        value = $($target).data('value-without-fees')
        $('[data-pay-payment-fee]').val('0')

      $input.val("#{$input.data('total-text')} #{value}") if value
