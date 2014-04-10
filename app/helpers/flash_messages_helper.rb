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
    content = message.is_a?(Hash) ? message[:message] : message

    content_tag(:div, class: 'row') do
      concat(content_tag(:div,
                         class:          html_classes_for_msg(name, message),
                         'data-alert' => 'true') do

        concat(content.html_safe)
        concat(link_to('&times;'.html_safe, '#', class: 'close'))
      end)
    end
  end

  def html_classes_for_msg(name, message)
    html_classes  = "#{name} alert-box large-10 columns large-centered animated fadeIn"
    html_classes << ' dismissible' unless message.is_a?(Hash) && !message[:dismissible]
    html_classes
  end

  def filtered_flash_messages
    flash.select do |message|
      %i(alert notice).include? message.first
    end.to_h
  end
end
