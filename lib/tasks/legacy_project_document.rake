require 'bogie'
include Bogie

namespace :db do
  namespace :migrate do
  
    desc 'Migrates project_documents'
    task project_documents: :environment do
      Bogie.run :project_documents
    end

  end
end