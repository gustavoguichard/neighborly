Neighborly.Devise ?= {}
Neighborly.Devise.Registrations ?= {}

Neighborly.Devise.Registrations.New =
  init: ->
    $('#show_password').change ->
      $password = $('#user_password')

      if $('#show_password').is(':checked')
        $password.prop 'type', 'text'
      else
        $password.prop 'type', 'password'
