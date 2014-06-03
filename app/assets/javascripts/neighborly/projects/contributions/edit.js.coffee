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
      $('#pay_payment_fees').on 'change', =>
        @payment_view.togglePaymentFee()
      @payment_view.togglePaymentFee()

    openFaqText: (e)->
      e.preventDefault()
      $(e.currentTarget).parent().find('p').toggleClass('hide')
