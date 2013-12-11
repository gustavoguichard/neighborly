Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Backers = {} if Neighborly.Projects.Backers is undefined

Neighborly.Projects.Backers.Edit =
  modules: -> [Neighborly.CustomTooltip]
  init: Backbone.View.extend
    el: '.create-backer-page'

    events:
      'click .faqs a': 'openFaqText'

    initialize: ->
      @payment_view = new this.Payment()

    openFaqText: (e)->
      e.preventDefault()
      $(e.currentTarget).parent().find('p').toggleClass('hide')

    Payment: Backbone.View.extend
      el: '.create-backer-page .payment'

      initialize: ->
        _.bindAll this, 'showContent'
        this.$('.methods input').change this.showContent
        this.$('.methods input:first').click()

      showContent: (e)->
        this.showTotalValue(e)
        this.$('.payment-method').addClass('loading-section')
        $payment = $("##{$(e.currentTarget).val()}-payment.payment-method")

        if $payment.data('path')
          $.get($payment.data('path')).success (data) =>
            this.$('.payment-method').hide()
            $payment.html data
            $payment.show()
            this.$('.payment-method').removeClass('loading-section')

      showTotalValue: (e)->
        $input = $('.create-backer-page header .total-with-fee input')
        $input.val("#{$input.data('total-text')} #{$(e.target).data('value-with-taxes')}")
