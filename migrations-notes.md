# TODO

# IMPORTANT

# USE migration branch

Need configurate the s3 access for legacy dragonfly

Change uploaders to save files on Amazon S3

See about the catarse_fee

## Before

On old neighbor.ly, use migration branch and run rake db:migrate, after get an updated database from heroku.

On new neighbor.ly, run `rake db:create`, `rake db:migrate` and on `rails console`: 
	
	Category.destroy_all
	

## After migrate configurations

Reset sequesces and create configuration for aws and notifications types


## Migration

This will migrate the data from older database to the new
	
	rake db:migrate:configurations
	
	rake db:migrate:categories
	
	rake db:migrate:states
	
	rake db:migrate:press_assets
	
	rake db:migrate:oauth_providers
		
	rake db:migrate:users
	
	rake db:migrate:authorizations
	
	rake db:migrate:projects
	
	rake db:migrate:rewards
	
	rake db:migrate:backers
	
	rake db:migrate:updates
	
	rake db:migrate:project_faqs
	
	rake db:migrate:project_documents


## Reset sequences on postgres

As the migration insert the same id that was on old database, postgres don't update the id sequence, so we need todo this manualy.

	rake db:reset_sequences

## Insert the new configurations for Neighbor.ly

	rake db:seed:neighborly


## To populate the routing number table


	rake update_routing_numbers

# After migration

In order to prevent some problems on migrations, I commented some codes and they need put back..

Find by `ADD BACK - REMOVED FOR MIGRATION` in the project and uncomment the code.


