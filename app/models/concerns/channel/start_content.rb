module Channel::StartContent
  extend ActiveSupport::Concern

  included do
    include AutoHtml
    mount_uploader :start_hero_image, HeroImageUploader

    def start
      @start ||= OpenStruct.new(start_content)
    end

    def start_primary_content_html
      auto_html(start.start_primary_content) do
        redcarpet markdown_options: { autolink: true, filter_html: true, hard_wrap: true, link_attributes: { target: :blank, data: { :"no-turbolink" => true } } }
      end
    end

    def start_secondary_content_html
      auto_html(start.start_secondary_content) do
        redcarpet markdown_options: { autolink: true, filter_html: true, hard_wrap: true, link_attributes: { target: :blank, data: { :"no-turbolink" => true } } }
      end
    end
  end
end
