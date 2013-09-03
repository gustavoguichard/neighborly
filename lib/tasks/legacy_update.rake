require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates updates'
    task updates: :environment do
      Bogie.run :updates
    end

  end
end