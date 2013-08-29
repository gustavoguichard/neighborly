require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates press_assets'
    task press_assets: :environment do
      Bogie.run :press_assets
    end

  end
end