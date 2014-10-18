module TabLinkToHelper
  def tab_link_to(name = nil, url = nil, attrs = nil, &block)
    url = name if block_given?

    html_options = if current_page?(url)
      attrs.to_h.merge(class: 'selected')
    else
      attrs.to_h
    end

    if block_given?
      link_to(name, html_options, &block)
    else
      link_to(name, url, html_options)
    end
  end
end
