module CatarseAutoHtml
  AutoHtml.add_filter(:email_image).with(width: 200) do |text, options|
    text.gsub(/http(s)?:\/\/.+\.(jpg|jpeg|bmp|gif|png)(\?\S+)?/i) do |match|
      width = options[:width]
      %|<img src="#{match}" alt="" style="max-width:#{width}px" />|
    end
  end

  def catarse_auto_html_for options={}
    self.auto_html_for options[:field] do
      unless options[:not_escape_html]
        html_escape map: {
          '&' => '&amp;',
          '>' => '&gt;',
          '<' => '&lt;',
          '"' => '"' }
      end

      twitter align: "center"
      iframe width: 640
      youtube width: options[:video_width], height: options[:video_height], wmode: "opaque"
      vimeo width: options[:video_width], height: options[:video_height]
      redcarpet markdown_options: { autolink: true, filter_html: true, link_attributes: { target: :blank, data: { :"no-turbolink" => true } }, hard_wrap: true }
      #image
      #redcloth target: :_blank
      #link target: :_blank
    end
  end
end
