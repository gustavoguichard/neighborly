#encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "catarse_echeck_net/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "catarse_echeck_net"
  s.version     = CatarseEcheckNet::VERSION
  s.authors     = ["Antônio Roberto Silva"]
  s.email       = ["forevertonny@gmail.com"]
  s.homepage    = "http://github.com/luminopolis/catarse_echeck_net"
  s.summary     = "Authorize.Net eCheck integration with Catarse"
  s.description = "Authorize.Net eCheck integration with Catarse crowdfunding platform"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "authorize-net", "~> 1.5.2"
end
