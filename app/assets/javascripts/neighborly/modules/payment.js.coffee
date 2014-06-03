Neighborly.Payment = Backbone.View.extend
  el: '.payment'

  initialize: ->
    _.bindAll this, 'showContent'
    this.$('.methods input').click (e) =>
      this.showContent(e)
      this.togglePaymentFee(e)
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

  togglePaymentFee: (e)->
    $input = $('.total-value input')
    $target = this.$('.methods input:checked')
    if $('[is-paying-fees]').length || $('#pay_payment_fees').is(':checked')
      value = $($target).data('value-with-fees')
      $('[data-pay-payment-fee]').val('1')
    else
      value = $($target).data('value-without-fees')
      $('[data-pay-payment-fee]').val('0')

    $input.val("#{$input.data('total-text')}#{value}") if value

  updatePaymentFeeInformationOnEngine: ->
    return if $('#pay_payment_fees').length == 0
    if $('#pay_payment_fees').is(':checked')
      $('[data-pay-payment-fee]').val('1')
    else
      $('[data-pay-payment-fee]').val('0')
