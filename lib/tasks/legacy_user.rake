require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates users'
    task users: :environment do
      Bogie.run :users
    end

  end
end