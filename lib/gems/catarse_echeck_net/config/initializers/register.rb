begin
  PaymentEngines.register({name: 'echeck_net', review_path: ->(backer){ CatarseEcheckNet::Engine.routes.url_helpers.review_echeck_net_path(backer) }, locale: 'en'})
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
