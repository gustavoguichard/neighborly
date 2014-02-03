###
# Application's tasks.
# These task are required by the application.
# They are used on Heroku Scheduler.
###

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Project.to_finish.each do |project|
    CampaignFinisherWorker.perform_async(project.id)
  end
end

desc "This tasks should be executed 1x per day"
task notify_project_owner_about_new_confirmed_contributions: :environment do
  Project.with_contributions_confirmed_today.each do |project|
    Notification.notify_once(
      :project_owner_contribution_confirmed,
      project.user,
      {user_id: project.user.id, project_id: project.id, 'notifications.created_at' => Date.today},
      {project: project}
    )
  end
end

desc "Move to deleted state all contributions that are in pending a lot of time"
task :move_pending_contributions_to_trash => [:environment] do
  Contribution.where("state in('pending') and created_at + interval '6 days' < current_timestamp").update_all({state: 'deleted'})
end

desc "Cancel all waiting_confirmation contributions that is passed 4 weekdays"
task :cancel_expired_waiting_confirmation_contributions => :environment do
  Contribution.can_cancel.update_all(state: 'canceled')
end

desc "Checking echeck payments"
task :check_echeck => [:environment] do
  Contribution.where(%Q{
    state <> 'confirmed' AND payment_method = 'eCheckNet' AND payment_id IS NOT NULL
  }).each do |contribution|
    _test = (Configuration[:test_payments] == 'true')

    an_login_id = ::Configuration[:authorizenet_login_id]
    an_transaction_key = ::Configuration[:authorizenet_transaction_key]
    an_gateway = _test ? :sandbox : :production

    reporting = AuthorizeNet::Reporting::Transaction.new(an_login_id, an_transaction_key, :gateway => an_gateway)
    details = reporting.get_transaction_details(contribution.payment_id)

    if details and details.transaction.present?
      transaction = details.transaction
      contribution.confirm! if transaction.status == 'settledSuccessfully'
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
