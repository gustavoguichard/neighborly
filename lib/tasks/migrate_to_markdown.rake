namespace :markdown do
  desc "This task will migrate projects textile to markdown"
  task :migrate_projects => :environment do

    # Project => about, budget, terms
    # Update => comment

    Project.all.each do |project|
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

  desc "This task will migrate updates textile to markdown"
  task :migrate_update => :environment do
    Update.all.each do |update|
      puts "Migrating update ##{update.id}"

      # copy textile to new field
      if update.comment.nil?
        update.comment_textile = update.comment
      end

      p = HTMLPage.new contents: convert_to_html(update.comment)
      update.comment = p.markdown!

      update.save
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
