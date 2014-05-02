Neighborly.Payment = Backbone.View.extend
  el: '.payment'

  initialize: ->
    _.bindAll this, 'showContent'
    this.$('.methods input').click this.showContent
    this.$('.methods input:first').click()

  showContent: (e)->
    this.$('.payment-method-option').removeClass('selected')
    $(e.currentTarget).parents('.payment-method-option').addClass('selected')
    this.$('.container .loading').addClass('show')
    this.$('.payment-method').addClass('loading-section')
    $payment = $("##{$(e.currentTarget).val()}-payment.payment-method")

    if $payment.data('path')
      $.get($payment.data('path')).success (data) =>
        this.$('.payment-method').html('')
        $payment.html data
        Initjs.initializePartial()
        $payment.show()
        this.$('.payment-method').removeClass('loading-section')
        this.updatePaymentFeeInformationOnEngine()
        this.$('.container .loading').removeClass('show')

  updatePaymentFeeInformationOnEngine: ->
    return if $('#pay_payment_fees').length == 0
    if $('#pay_payment_fees').is(':checked')
      $('[data-pay-payment-fee]').val('1')
    else
      $('[data-pay-payment-fee]').val('0')
