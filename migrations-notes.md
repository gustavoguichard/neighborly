Need configurate the s3 access for legacy dragonfly


rake db:migrate:configurations

rake db:migrate:categories

rake db:migrate:states

rake db:migrate:press_assets

rake db:migrate:users

rake db:migrate:oauth_providers

rake db:migrate:authorizations

rake db:migrate:projects

rake db:migrate:rewards

rake db:migrate:backers

rake db:migrate:updates

rake db:migrate:project_faqs

rake db:migrate:project_documents





rake db:reset_sequences



rake update_routing_numbers

ActiveRecord::Base.connection.reset_pk_sequence!('oauth_providers')
