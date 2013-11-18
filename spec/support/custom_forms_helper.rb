module CustomFormsHelper
  def foundation_select(option, opts={})
    # Zurb Foundation adds custom markup after (and then hides)
    # the originating select. Here we simulate the user's interaction
    # with the custom form instead of just setting the hidden originating select's value
    originating_select_name = opts[:from]

    custom_select = find("select[name='#{originating_select_name}'] + .custom.dropdown")
    # click dropdown trigger
    custom_select.find('a.selector').click
    # click option li with correct option text
    custom_select.find('li', text: option).click
  end
end
