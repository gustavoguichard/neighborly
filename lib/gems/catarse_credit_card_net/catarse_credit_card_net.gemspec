$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_credit_card_net/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "catarse_credit_card_net"
  s.version     = CatarseCreditCardNet::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CatarseCreditCardNet."
  s.description = "TODO: Description of CatarseCreditCardNet."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"

  s.add_development_dependency "sqlite3"
end
