require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates configurations'
    task configurations: :environment do
      Bogie.run :configurations
    end

  end
end