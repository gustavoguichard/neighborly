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
      {user_id: project.user.id, project_id: project.id, 'projects.created_at::date' => Date.today},
      project.user,
      project: project
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
  p2 = Project.where('image_url is not null').all - p1
  p3 = Project.where('video_url is not null').all - p1 - p2

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
      project.uploaded_image = open(project.image_url)
      puts "Downloading thumbnail: #{project.id} - #{project.name}"
      project.save!
    rescue Exception => e
      puts "Couldn't read #{project.image_url} on project #{project.id}, downloading thumbnail from video..."
      project.download_video_thumbnail
      project.save! if project.valid?
    end
  end

  p3.each do |project|
    begin
      project.download_video_thumbnail
      puts "Downloading thumbnail from video: #{project.id} - #{project.name}"
      project.save!
    rescue Exception => e
      puts "Couldn't read: #{project.video_url}"
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

