module FlashMessagesHelper
  def flash_messages
    content_tag :div, class: 'flash' do
      filtered_flash_messages.map do |name, message|
        concat build_flash_message(name, message)
      end
    end if filtered_flash_messages.any?
  end

  private

  def build_flash_message(name, message)
    persistent = (message.is_a?(Hash) && !message[:dismissible])

    content = message.is_a?(Hash) ? message[:message] : message

    content_tag(:div, class: persistent ? 'row' : 'fixed') do
      concat(content_tag(:div,
                         class: html_classes_for_msg(name, persistent),
                         data: { alert: :true }) do

        concat(content.html_safe)
        concat(link_to('&times;'.html_safe, '#', class: 'close'))
      end)
    end
  end

  def html_classes_for_msg(name, persistent)
    html_classes = "#{name} alert-box animated fadeIn text-center"
    if persistent
      html_classes << ' persistent large-10 columns large-centered'
    else
      html_classes << ' dismissible'
    end

    html_classes
  end

  def filtered_flash_messages
    flash.select do |message|
      %w(alert notice).include? message.first
    end.to_h
  end
end
