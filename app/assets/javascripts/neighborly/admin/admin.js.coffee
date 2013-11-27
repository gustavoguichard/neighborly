Neighborly.Admin ?= {} if Neighborly.Admin is undefined

Neighborly.Admin.modules =-> [Neighborly.Admin.Common, Neighborly.Admin.Modules.Sort]

Neighborly.Admin.Common = Backbone.View.extend
  el: '.admin'

  initialize: ->
    $('.best_in_place').best_in_place()
