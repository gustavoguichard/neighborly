require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates authorizations'
    task authorizations: :environment do
      Bogie.run :authorizations
    end

  end
end