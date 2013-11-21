window.CatarseEcheckForm = Backbone.View.extend
  el: ".catarse-echeck-net-form"
  events:
    "submit form#echeck_form": "submitEcheck"

  initialize: ->
    _.bindAll(this, 'validate', 'submit')

    this.$button = this.$('input[type=submit]')
    this.$form = this.$('form#echeck-form')

    this.$('#routing_number, #account_number, #account_holder_name').focusout =>
      this.validate()

    this.$form.bind('submit', this.submit)
    this.showAuthorizeNetSeal()

  submit: (e) ->
    e.preventDefault()
    return false unless this.validate()

    data =
      routing_number: this.$("#routing_number").val()
      account_number: this.$("#account_number").val()
      bank_name: this.$("#bank_name").val()
      account_holder_name: this.$("#account_holder_name").val()

    $.post(this.$form.prop('action'), data, (response) =>
      if response.process_status is "ok"
        location.href = $('.create-backer-page').data('thank-you-path')
      else
        this.$('.check-error p.error-name').text response.message
        this.$('.check-error').fadeIn 300
        $.rails.enableFormElements(this.$form)
    , "json").error ->
      this.$('.check-error p.error-name').text 'The back already confirmed, if you can do another back please refresh the page or go back to project page :)'
      this.$('.check-error').fadeIn 300

  checkRoutingNumber: ($field) ->
    number = $.trim($field.val())
    if number.length is 9
      $.getJSON "/payment/echeck_net/check_routing_number",
        number: number
      , (response) =>
        if response.ok
          this.removeError $field
          this.$("#bank_name").val response.bank_name
          return true
        else
          this.addError $field, 'Invalid Routing Number'
          return false

    else
      this.addError $field, 'Invalid Routing Number'
      return false

  validate: ->
    valid = true
    valid = false unless this.validateField this.$('#account_holder_name')
    valid = false unless this.validateField this.$('#routing_number')
    valid = false unless this.validateField this.$('#account_number')
    valid = false unless this.checkRoutingNumber this.$("#routing_number")

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
