namespace :markdown do
  desc "This task will migrate the textile to markdown"
  task :migrate => :environment do

    # Project => about, budget, terms
    # Update => comment
    #

    ignore = [9]

    Project.where('id not IN (?)', ignore).limit(1).each do |project|
      puts "Migrating project ##{project.id}"

      # copy textile to new field
      if project.about_textile.nil?
        project.about_textile = project.about
      end

      if project.budget_textile.nil?
        project.budget_textile = project.budget
      end

      if project.terms_textile.nil?
        project.terms_textile = project.terms
      end


      p = HTMLPage.new contents: convert_to_html(project.about)
      project.about = p.markdown!

      p = HTMLPage.new contents: convert_to_html(project.budget)
      project.budget = p.markdown!

      p = HTMLPage.new contents: convert_to_html(project.terms)
      project.terms = p.markdown!

      project.save
    end


  end

  include AutoHtml

  def convert_to_html(text)
    auto_html(text) do
      #html_escape map: {
        #'&' => '&amp;',
        #'>' => '&gt;',
        #'<' => '&lt;',
        #'"' => '"' }

      #tweets align: "center"
      #iframe width: 640
      image
      #youtube width: options[:video_width], height: options[:video_height], wmode: "opaque"
      #vimeo width: options[:video_width], height: options[:video_height]
      redcloth target: :_blank
      link target: :_blank
    end
  end

end
