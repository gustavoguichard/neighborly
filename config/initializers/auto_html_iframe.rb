AutoHtml.add_filter(:iframe).with(align: nil, width: nil, omit_script: true, lang: 'en') do |text, options|
  regex = /\[if=\[(.*)\] height=\[(.*)\]\]/
  width = options[:width] || 640
  #raise text.gsub(regex).inspect
  text.gsub(regex) do
    url = $1
    url.gsub!(/https?\:\/\//, '//')

    text.match(regex)
    height = $2 || 600
    %{<iframe src="#{url}" width="#{width}" height="#{height}"></iframe>}
  end
end
