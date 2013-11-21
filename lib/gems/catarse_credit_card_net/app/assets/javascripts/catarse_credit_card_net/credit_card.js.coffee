window.CreditCardNetForm = Backbone.View.extend
  el: '.catarse-credit-card-net-form'

  initialize: ->
    _.bindAll(this, 'validate', 'submit')
    this.$el.foundation()

    this.$button = this.$('input[type=submit]')
    this.$form = this.$('form#credit-card-form')

    this.$('#billing_first_name, #billing_last_name, #card_number, #card_code').focusout =>
      this.validate()

    this.$form.bind('submit', this.submit)

    this.showAuthorizeNetSeal()

  submit: (e) ->
    e.preventDefault()
    return false unless this.validate()

    data =
      card_number: this.$('#card_number').val()
      card_code: this.$('#card_code').val()
      card_month: this.$('#card_month').val()
      card_year: this.$('#card_year').val()
      billing_first_name: this.$('#billing_first_name').val()
      billing_last_name: this.$('#billing_last_name').val()

    $.post(this.$form.prop('action'), data, (response) =>
      console.log response
      if response.process_status is 'ok'
        location.href = $('.create-backer-page').data('thank-you-path')
      else
        this.$('.check-error p.error-name').text response.message
        this.$('.check-error').fadeIn 300
        $.rails.enableFormElements(this.$form)
    , 'json').error ->
      this.$('.check-error p.error-name').text 'The back already confirmed, if you can do another back please refresh the page or go back to project page :)'
      this.$('.check-error').fadeIn 300

  validate: ->
    valid = true
    valid = false unless this.validateField this.$('#billing_first_name')
    valid = false unless this.validateField this.$('#billing_last_name')
    valid = false unless this.validateField this.$('#card_number')
    valid = false unless this.validateField this.$('#card_code')

    return valid

  validateField: ($field) ->
    value = $.trim(this.replaceAll($field.val(), '_', ''))
    if value and value.length > 0
      this.removeError($field)
      return true
    else
      this.addError($field)
      return false

  addError: ($field, message)->
    message = 'This field is required.' unless message?
    $field.addClass 'error'
    $field.parent().find('span.error').remove()
    $field[0].insertAdjacentHTML 'afterend', "<span class='error'>#{message}</span>"

  removeError: ($field)->
    $field.removeClass 'error'
    $field.parent().find('span.error').remove()

  replaceAll: (string, token, newtoken) ->
    return string unless string && string.length > 0
    string = string.replace(token, newtoken) until string.indexOf(token) is -1
    string

  showAuthorizeNetSeal: ->
    this.$('.AuthorizeNetSeal').html $('.seal-original .AuthorizeNetSeal').html()
