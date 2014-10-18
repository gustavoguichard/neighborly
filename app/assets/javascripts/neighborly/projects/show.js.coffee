Neighborly.Projects = {} if Neighborly.Projects is undefined

Neighborly.Projects.modules =-> [Neighborly.Tabs, Neighborly.Projects.Show.StatusBar, Neighborly.Projects.Show.AskQuestion]

Neighborly.Projects.Show =
  init: ->

  AskQuestion: ->
    if window.location.hash == '#open-new-user-question-modal'
      $('a[data-reveal-id=ask-a-question]').trigger('click')
