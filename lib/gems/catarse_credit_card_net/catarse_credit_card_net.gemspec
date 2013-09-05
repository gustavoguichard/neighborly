$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_credit_card_net/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "catarse_credit_card_net"
  s.version     = CatarseCreditCardNet::VERSION
  s.authors     = ["Antônio Roberto Silva", "Josemar Davi Luedke"]
  s.email       = ["forevertonny@gmail.com", "josemarluedke@gmail.com"]
  s.homepage    = "http://github.com/luminopolis/catarse_credit_card_net"
  s.summary     = "Credit card Authorize.Net integration with Catarse"
  s.description = "Credit card Authorize.Net integration with Catarse crowdfunding platform"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "authorize-net", "~> 1.5.2"

  s.add_development_dependency "sqlite3"
end
