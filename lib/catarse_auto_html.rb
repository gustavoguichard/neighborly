module CatarseAutoHtml
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
      iframe width: 720
      youtube width: options[:video_width], height: options[:video_height], wmode: "opaque"
      vimeo width: options[:video_width], height: options[:video_height]
      redcarpet markdown_options: { autolink: true, filter_html: true, hard_wrap: true, link_attributes: { target: :blank, data: { :"no-turbolink" => true } } }
    end
  end
end
