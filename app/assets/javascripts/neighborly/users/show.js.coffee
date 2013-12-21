Neighborly.Users = {} if Neighborly.Users is undefined


Neighborly.Users.Show =
  init: Backbone.View.extend
    el: '.user-profile-page'

    initialize: ->
      if this.$('.map-canvas').length > 0
        this.map = new Neighborly.Map()
