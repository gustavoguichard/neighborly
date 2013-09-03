require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates backers'
    task backers: :environment do
      Bogie.run :backers
    end

  end
end