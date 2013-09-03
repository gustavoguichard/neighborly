require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates states'
    task states: :environment do
      Bogie.run :states
    end

  end
end