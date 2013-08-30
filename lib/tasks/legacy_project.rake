require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates projects'
    task projects: :environment do
      Bogie.run :projects
    end

  end
end