Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Contributions = {} if Neighborly.Projects.Contributions is undefined

Neighborly.Projects.Contributions.Edit =
  modules: -> [Neighborly.CustomTooltip]
  init: Backbone.View.extend
    el: '.create-contribution-page'

    events:
      'click .faqs a': 'openFaqText'

    initialize: ->
      @payment_view = new this.Payment()

    openFaqText: (e)->
      e.preventDefault()
      $(e.currentTarget).parent().find('p').toggleClass('hide')

    Payment: Backbone.View.extend
      el: '.create-contribution-page .payment'

      initialize: ->
        _.bindAll this, 'showContent'
        this.$('.methods input').click this.showContent
        $('.create-contribution-page #pay_payment_fees').on 'change', this.showTotalValue
        this.$('.methods input:first').click()
        this.showTotalValue()

      showContent: (e)->
        this.showTotalValue(e)
        this.$('.payment-method').addClass('loading-section')
        $payment = $("##{$(e.currentTarget).val()}-payment.payment-method")

        if $payment.data('path')
          $.get($payment.data('path')).success (data) =>
            this.$('.payment-method').hide()
            $payment.html data
            Initjs.initializePartial()
            $payment.show()
            this.$('.payment-method').removeClass('loading-section')

      showTotalValue: =>
        $input = $('.create-contribution-page header .total-value input')
        $target = this.$('.methods input:checked')
        if $('.create-contribution-page #pay_payment_fees').is(':checked')
          value = $($target).data('value-total-with-fees')
        else
          value = $($target).data('value-total-without-fees')

        $input.val("#{$input.data('total-text')} #{value}") if value
