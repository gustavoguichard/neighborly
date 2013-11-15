Neighborly.CustomTooltip =->
  $('.custom-tooltip a').unbind('click')
  $('.custom-tooltip a').click (e)->
    e.preventDefault()
    $target = $(e.target).parents('.custom-tooltip').find('.tooltip-content')
    $('.tooltip-content').not('.hide').not($target).toggleClass('hide')
    $target.toggleClass('hide')
