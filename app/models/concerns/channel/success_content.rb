module Channel::SuccessContent
  extend ActiveSupport::Concern

  included do
    include AutoHtml

    def success
      @success ||= OpenStruct.new(success_content)
    end

    def success_main_text_html
      auto_html(success.main_text) do
        redcarpet markdown_options: { autolink: true, filter_html: true, hard_wrap: true, link_attributes: { target: :blank, data: { :"no-turbolink" => true } } }
      end
    end
  end
end
