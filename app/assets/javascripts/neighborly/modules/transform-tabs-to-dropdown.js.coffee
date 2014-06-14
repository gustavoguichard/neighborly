Neighborly.TransformTabsToDropdown =
  init: ->
    $tabs = $('nav.tabs')

    $('ul', $tabs).attr('id', 'dropdown-from-tabs').addClass('f-dropdown')
    $('[data-dropdown]', $tabs).remove()
    $link = $('<a>').addClass('button dropdown').attr('data-dropdown', 'dropdown-from-tabs').html('Menu')
    $tabs.prepend($link)
    $('[data-dropdown]', $tabs).html($('li a.selected', $tabs).html())

    $('ul a', $tabs).click ->
      $('[data-dropdown]', $tabs).html($(this).html())
      Foundation.libs.dropdown.close($('#dropdown-from-tabs'))
