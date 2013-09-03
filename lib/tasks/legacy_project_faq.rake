require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates project_faqs'
    task project_faqs: :environment do
      Bogie.run :project_faqs
    end

  end
end