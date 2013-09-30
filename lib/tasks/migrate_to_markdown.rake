namespace :markdown do
  desc "This task will migrate projects textile to markdown"
  task :migrate_projects => :environment do

    # Project => about, budget, terms
    # Update => comment

    Project.where(id: [46, 55, 54, 53]).each do |project|
      puts "Migrating project ##{project.id}"

      # copy textile to new field
      unless project.about_textile.present?
        project.about_textile = project.about

        p = HTMLPage.new contents: convert_to_html(project.about_textile)
        project.about = p.markdown!
      end

      unless project.budget_textile.present?
        project.budget_textile = project.budget

        p = HTMLPage.new contents: convert_to_html(project.budget_textile)
        project.budget = p.markdown!
      end

      unless project.terms_textile.present?
        project.terms_textile = project.terms

        p = HTMLPage.new contents: convert_to_html(project.terms_textile)
        project.terms = p.markdown!
      end

      puts "RESULT: #{project.save}"
      puts "--- ERRORS: #{project.errors.inspect}"
    end
  end

  desc "This task will migrate updates textile to markdown"
  task :migrate_updates => :environment do
    Update.all.each do |update|
      puts "Migrating update ##{update.id}"

      # copy textile to new field
      unless update.comment_textile.present?
        update.comment_textile = update.comment

        p = HTMLPage.new contents: convert_to_html(update.comment_textile)
        update.comment = p.markdown!

        update.save
      end
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
