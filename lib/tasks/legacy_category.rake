require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates categories'
    task categories: :environment do
      Bogie.run :categories
    end

  end
end