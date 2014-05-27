require 'factory_girl'
factories_file = Rails.root.join('spec', 'factories.rb')
eval(File.open(factories_file).read)
