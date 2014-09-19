Neighborly.Projects.Contributions = {} if Neighborly.Projects.Contributions is undefined

Neighborly.Projects.Contributions.New =
  modules: -> []

  init: ->(
    initialize: ->
      $('.maturity-option .header').click this.boxClicked
      $('.order-size-input').on 'keyup', this.orderSizeChanged

    boxClicked: (event) ->
      $('.maturity-option').removeClass('selected')
      $box = $(event.currentTarget).parents('.maturity-option:first')
      $box.addClass('selected')

    orderSizeChanged: (event) ->
      $input = $(event.currentTarget)
      if $input.val() != ''
        $box = $(event.currentTarget).parents('.maturity-option:first')
        minimum_investment = $input.data('minimum-investment')
        amount = parseInt($input.val()) * parseFloat($input.data('minimum-investment'))
        $box.find('.value-input').val(amount)
        $box.find('.purchase-amount .amount').html(numeral(amount).format('$0,0'))
  ).initialize()
