namespace :db do
  desc "Reset all sequences. Run after data imports"
  task :reset_sequences, [:model_class] => :environment do |t, args|
    if args[:model_class]
      classes = Array(eval args[:model_class])
    else
      puts "using all defined active_record models"
      classes = []
      Dir.glob(Rails.root + '/app/models/**/*.rb').each { |file| require file }
      ActiveRecord::Base.subclasses.select { |c|c.base_class == c}.sort_by(&:name).each do |klass|
        classes << klass
      end
    end
    #classes = [Authorization]
    classes.each do |klass|
      puts "reseting sequence on #{klass.table_name}"
      ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name) rescue puts("#{klass.table_name} --- THIS TABLE HAS AN ERROR --- Check if necessary")
    end
  end
end
