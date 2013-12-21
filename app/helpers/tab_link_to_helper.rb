module TabLinkToHelper
  def tab_link_to(name = nil, url = nil, klass = nil, &block)
    if block_given?
      url = name
      link_to(url, class: " #{ 'selected' if current_page?(url) } #{klass}", &block)
    else
      link_to(name, url, class: " #{ 'selected' if current_page?(url) } #{klass}")
    end
  end
end
