begin
  PaymentEngines.register({name: 'credit_card_net', review_path: ->(backer){ CatarseCreditCardNet::Engine.routes.url_helpers.review_credit_card_net_path(backer) }, locale: 'en'})
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
