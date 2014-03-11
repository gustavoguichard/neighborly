module FlashMessagesHelper
  def flash_messages
    content_tag :div, class: 'flash' do

      filtered_flash_messages.map do |name, message|
        content       = message.try(:[], :message) || message
        html_classes  = "#{name} alert-box large-10 columns large-centered animated fadeIn"
        html_classes << ' dismissible' if !!message.try(:dismissible)

        concat(content_tag(:div, class: 'row') do
          concat(content_tag(:div, class: html_classes, 'data-alert' => 'true') do

            concat(content.html_safe)
            concat(link_to('&times;'.html_safe, nil, class: 'close'))
          end)
        end)
      end

    end if filtered_flash_messages.any?
  end

  private

  def safe_buffer(&block)
    buffer = ActiveSupport::SafeBuffer.new
    yield buffer if block_given?
    buffer
  end

  def filtered_flash_messages
    flash.select do |message|
      %i(alert notice).include? message.first
    end.to_h
  end
end
