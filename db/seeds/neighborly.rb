
puts "Adding new configurations..."
  {
    company_name: 'Neighbor.ly',
    host: 'neighbor.ly',
    base_url: "http://neighbor.ly",
    blog_url: "http://blog.neighbor.ly",
    email_contact: 'howdy@neighbor.ly',
    email_payments: 'books@neighbor.ly',
    email_projects: 'projects@neighbor.ly',
    email_system: 'no-reply@neighbor.ly',
    email_no_reply: 'no-reply@neighbor.ly',
    facebook_url: "http://www.facebook.com/NEIGHBORdotLY",
    facebook_app_id: '255971384512404',
    twitter_username: "Neighborly",
    mailchimp_url: "http://neighbor.us1.list-manage2.com/subscribe/post?u=21981001cfe713f8988f30c47&amp;id=40b2f2e36d",
    catarse_fee: '0.05', # TODO
    support_forum: 'http://neighborly.uservoice.com/',
    base_domain: 'neighbor.ly',
    uservoice_key: 'Diz5MR8dh3fxawPFOcrw',
    project_finish_time: '02:59:59',
    mandrill_user_name: 'luminopolis',
    secret_token: '8f3af8dc08112fa30556493dffc1e8ce971209c8e40f41499ba5c7b8fc62fd1a40418451cffba9a18fdfb19e04b891fc671d183934bcafbd314553462524e71f',
    secret_key_base: '2981daa58d834ae67e95752a9d67094b6cf585c3a329c621350ee5d5a6b970a7ab51a7720932d0c7de07c6c8eb417df8da936ad291e1daae190d820d05fcd007',
    currency_charge: :USD,
    secure_review_host: 'secure.neighbor.ly'
  }.each do |name, value|
     conf = Configuration.find_or_initialize_by(name: name)
     conf.update_attributes({
       value: value
     })
  end

puts "Adding the notification types..."
  [
  'confirm_backer','payment_slip','project_success','backer_project_successful',
  'backer_project_unsuccessful','project_received', 'project_received_channel', 'updates','project_unsuccessful',
  'project_visible','processing_payment','new_draft_project', 'new_draft_channel', 'project_rejected',
  'pending_backer_project_unsuccessful', 'project_owner_backer_confirmed', 'adm_project_deadline',
  'project_in_wainting_funds', 'credits_warning', 'backer_confirmed_after_project_was_closed',
  'backer_canceled_after_confirmed', 'new_user_registration', 'new_project_visible'
].each do |name|
  NotificationType.find_or_create_by(name: name)
end


puts "Adding new configurations for AWS..."
  {
    aws_access_key: 'AKIAJYKDLX3AUNWY2D3A',
    aws_secret_key: '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',
    aws_bucket: 'neighborly_new_production'
  }.each do |name, value|
     conf = Configuration.find_or_initialize_by(name: name)
     conf.update_attributes({
       value: value
     })
  end
