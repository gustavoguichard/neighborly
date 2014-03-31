Neighborly.Devise ?= {}
Neighborly.Devise.Registrations ?= {}

Neighborly.Devise.Registrations.New =
  init: ->
    $('#show_password').change ->
      $input = $('#show_password')
      $password = $('#user_password')

      if $input.is(':checked')
        $password.prop 'type', 'text'
      else
        $password.prop 'type', 'password'
