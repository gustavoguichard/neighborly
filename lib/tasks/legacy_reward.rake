require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates rewards'
    task rewards: :environment do
      Bogie.run :rewards
    end

  end
end