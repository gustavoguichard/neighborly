class Markdown::PreviewerController < ApplicationController
  include AutoHtml

  def create
    @html = auto_html(params[:markdown]) do
      options = {}
      options[:video_width] = 720
      options[:video_height] = 405

      twitter align: "center"
      iframe width: 720
      youtube width: options[:video_width], height: options[:video_height], wmode: "opaque"
      vimeo width: options[:video_width], height: options[:video_height]
      redcarpet markdown_options: { autolink: true, filter_html: true, hard_wrap: true, link_attributes: { target: :blank, data: { :"no-turbolink" => true } } }
    end

    render :show, layout: !request.xhr?
  end
end
