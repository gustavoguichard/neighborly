module TabLinkToHelper
  def tab_link_to(name = nil, url = nil, klass = nil, attrs = nil, &block)
    if block_given?
      url = name
      classes = if current_page?(url)
        klass.to_a.push('selected')
      else
      end
      link_to(url, attrs.to_h.merge(class: classes), &block)
    else
      link_to(name, url, attrs.to_h.merge(class: classes))
    end
  end
end
