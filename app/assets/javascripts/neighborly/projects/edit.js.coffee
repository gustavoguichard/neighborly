Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.Edit =
  init: Backbone.View.extend
    el: '.edit-project-page'

    initialize: ->
      this.$('#project_about, #project_budget, #project_terms').markItUp(Neighborly.markdownSettings)

      this.$('#project_tag_list').tagsInput
        autocomplete_url: $('.tags-path').data('url')
        width: '100%'
        height: '75px'

  modules: -> [Neighborly.SearchCities]
