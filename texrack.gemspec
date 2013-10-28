# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "texrack/version"

Gem::Specification.new do |s|
  s.name        = "texrack"
  s.version     = Texrack::VERSION
  s.authors     = ["Per Christian B. Viken"]
  s.email       = ["perchr@northblue.org"]
  s.homepage    = "https://github.com/PerfectlyNormal/texrack"
  s.summary     = %q{Rack microservice to render LaTeX as PNG}
  s.description = %q{texrack is a microservice that renders LaTeX as PNG files. Can be mounted in a Rack app}
  s.licenses    = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.rdoc_options = [%q{--main=README.md}]

  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.md"
  ]

  s.add_dependency 'sinatra', '~> 1.4.4'
  s.add_dependency 'rmagick', '~> 2.13.2'
end
