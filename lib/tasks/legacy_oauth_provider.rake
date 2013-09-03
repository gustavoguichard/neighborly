require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates oauth_providers'
    task oauth_providers: :environment do
      Bogie.run :oauth_providers
    end

  end
end