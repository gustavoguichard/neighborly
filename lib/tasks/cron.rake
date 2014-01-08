desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Project.to_finish.each do |project|
    CampaignFinisherWorker.perform_async(project.id)
  end
end

desc "This tasks should be executed 1x per day"
task notify_project_owner_about_new_confirmed_backers: :environment do
  Project.with_backers_confirmed_today.each do |project|
    Notification.notify_once(
      :project_owner_backer_confirmed,
      project.user,
      {user_id: project.user.id, project_id: project.id, 'notifications.created_at' => Date.today},
      {project: project}
    )
  end
end

desc "Move to deleted state all backers that are in pending a lot of time"
task :move_pending_backers_to_trash => [:environment] do
  Backer.where("state in('pending') and created_at + interval '6 days' < current_timestamp").update_all({state: 'deleted'})
end

desc "Cancel all waiting_confirmation backers that is passed 4 weekdays"
task :cancel_expired_waiting_confirmation_backers => :environment do
  Backer.can_cancel.update_all(state: 'canceled')
end

desc "Send notification about credits 1 month after the project failed"
task send_credits_notification: :environment do
  User.send_credits_notification
end

desc "Create first versions for rewards"
task :index_rewards_versions => :environment do
  Reward.all.each do |reward|
    unless reward.versions.count > 0
      puts "update! #{reward.id}"
      reward.update_attributes(reindex_versions: DateTime.now)
    end
  end
end


desc "Create reward title"
task :create_reward_title => :environment do
   Project.all.each do |project|
    puts "PROJECT: #{project.id} -- #{project.name}"
    i = 0
    project.rewards.rank(:row_order).each do |reward|
      i += 1
      puts "REWARD LEVEL: #{i} -- #{reward.minimum_value} -- ID: #{reward.id}"
      reward.update_attributes(title: "Level #{i}") unless reward.title.present?
    end
  end
end

desc "Update video_embed_url column"
task :fill_embed_url => :environment do
  Project.where('video_url is not null and video_embed_url is null').each do |project|
    project.update_video_embed_url
    project.save
  end
end

desc "Migrate project thumbnails to new format"
task :migrate_project_thumbnails => :environment do
  p1 = Project.where('uploaded_image is not null').all
  p2 = Project.where('video_url is not null').all - p1

  p1.each do |project|
    begin
      project.uploaded_image.recreate_versions! if project.uploaded_image.file.present?
      puts "Recreating versions: #{project.id} - #{project.name}"
    rescue Exception => e
      puts "Original image not found"
    end
  end

  p2.each do |project|
    begin
      project.download_video_thumbnail
      puts "Downloading thumbnail from video: #{project.id} - #{project.name}"
      project.save!
    rescue Exception => e
      puts "Couldn't read: #{project.video_url}"
    end
  end
end

desc "Migrate project hero images to new format"
task :migrate_project_hero_images => :environment do
  p1 = Project.where('hero_image is not null').all

  p1.each do |project|
    begin
      project.hero_image.recreate_versions! if project.hero_image.file.present?
      puts "Recreating versions: #{project.id} - #{project.name}"
    rescue Exception => e
      puts "Original image not found"
    end
  end
end

desc "Migrate company users logo"
task :migrate_company_users_logo => :environment do
  users = User.with_profile_type('company').where('company_logo is not null')

  users.each do |user|
    begin
      user.company_logo.recreate_versions!
      user.save!
      puts "Recreating versions: #{user.id} - #{user.company_name}"
    rescue Exception => e
      puts "Original image not found"
    end
  end
end

desc "Checking echeck payments"
task :check_echeck => [:environment] do
  Backer.where(%Q{
    state <> 'confirmed' AND payment_method = 'eCheckNet' AND payment_id IS NOT NULL
  }).each do |backer|
    _test = (Configuration[:test_payments] == 'true')

    an_login_id = ::Configuration[:authorizenet_login_id]
    an_transaction_key = ::Configuration[:authorizenet_transaction_key]
    an_gateway = _test ? :sandbox : :production

    reporting = AuthorizeNet::Reporting::Transaction.new(an_login_id, an_transaction_key, :gateway => an_gateway)
    details = reporting.get_transaction_details(backer.payment_id)

    if details and details.transaction.present?
      transaction = details.transaction
      backer.confirm! if transaction.status == 'settledSuccessfully'
    end
  end
end

desc "Update routing number table"
task :update_routing_numbers => :environment do
  url = URI.parse('http://www.fededirectory.frb.org/fpddir.txt');
  http = Net::HTTP.new(url.host, url.port);
  response = http.request(Net::HTTP::Get.new(url.request_uri));

  puts "Criando arquivo temporario"
  tmp_file = Tempfile.new("routing_numbers_#{DateTime.now.to_i}")
  tmp_file.write response.body
  tmp_file.rewind
  puts "temp file --> #{tmp_file.inspect}"

  tmp_file.each_line do |line|
    rn = line[0..8]
    bn = line[27...63]
    puts "#{rn} -- #{bn}"

    resource = RoutingNumber.find_or_create_by_number(rn)
    resource.bank_name = bn
    resource.save
  end
  tmp_file.unlink
end

desc "Fix the payment method from old backers"
task :fix_payment_method_from_old_backers => :environment do
  confirmed_backers = Backer.with_state('confirmed')

  confirmed_backers.where("
    backers.payment_token ~* '^EC.*' and lower(backers.payment_method) = lower('MoIP')
  ").update_all(payment_method: 'PayPal')

  confirmed_backers.where("
    lower(backers.payment_method) = lower('MoIP')
    and backers.created_at + interval '2 hours' < backers.confirmed_at
  ").update_all(payment_method: 'eCheckNet')

  confirmed_backers.where("
    lower(backers.payment_method) = lower('MoIP')
    and backers.created_at + interval '2 hours' > backers.confirmed_at
  ").update_all(payment_method: 'AuthorizeNet')

end


desc "Migrate Company to Organization"
task :migrate_company_to_organization => :environment do
  users = User.where(profile_type: 'company')

  users.each do |user|
    puts "USER #{user.id}"
    user.profile_type = 'organization'
    user.create_organization(name: user.company_name, remote_image_url: user.company_logo.url)
    saved = user.save
    puts "Saving user.... #{saved}"
    puts "ERROR: #{user.errors.messages.inspect}" if saved == false
  end
end

desc "Fix twitter url"
task :fix_twitter_url => :environment do
  users = User.where('twitter_url is not null')

  users.each do |user|
    if user.twitter_url.present?
      puts "USER #{user.id}"
      unless user.twitter_url[/\Ahttp:\/\/twitter.com/] || user.twitter_url[/\Ahttps:\/\/twitter.com/]
        user.twitter_url = "http://twitter.com/#{user.twitter_url}"
        saved = user.save
        puts "Saving user.... #{saved} #{user.twitter_url}"
        puts "ERROR: #{user.errors.messages.inspect}" if saved == false
      end
    end
  end
end

desc "Migrate documents filename to name field"
task :migrate_documents_filename => :environment do
  docs = ProjectDocument.all

  docs.each do |doc|
    puts "DOC #{doc.id}"
      doc.name = doc.document.filename
      saved = doc.save
      puts "Saving doc.... #{saved}"
      puts "ERROR: #{doc.errors.messages.inspect}" if saved == false
  end
end
