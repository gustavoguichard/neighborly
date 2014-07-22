module StaticPagesHelper
  def pricing_table_item(name, is_available)
    title, klass = if is_available
      ['Item included', %w(included icon-et-check)]
    else
      ['Item not included', %w(not-included icon-fa-remove)]
    end

    content_tag :li, class: 'bullet-item' do
      concat content_tag(:span, nil, class: klass, title: title)
      concat name
    end
  end
end
