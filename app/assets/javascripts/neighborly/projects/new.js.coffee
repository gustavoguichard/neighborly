Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.New =
  init: Backbone.View.extend
    el: '.new-project-page'

    initialize: ->
      _.bindAll(this, 'changeCategoryImage')
      this.$('#project_category_id').change this.changeCategoryImage

    changeCategoryImage: (event)->
      category = $(event.currentTarget).find(':selected').text().replace(/\s+/g, '-').toLowerCase()
      this.$el[0].className = this.$el[0].className.replace(/( category-.*)/, '')

      if category != 'select-an-option'
        this.$el.addClass("category-#{category}")

  modules: -> [Neighborly.SearchCities]
