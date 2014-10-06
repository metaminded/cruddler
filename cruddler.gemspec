# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cruddler/version"

Gem::Specification.new do |s|
  s.name        = "cruddler"
  s.version     = Cruddler::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "CRUD Actions for Lazy Coders"
  s.email       = "open-source@metaminded.com"
  s.homepage    = "http://github.com/metaminded/cruddler"
  s.description = "CRUD Actions for Lazy Coders, with just the correct amount of cifugurability."
  s.authors     = ['Peter Horn', 'Rene Sprotte']
  s.licenses    = ['MIT']
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]
  s.rdoc_options  = ['--charset=UTF-8']

  s.add_runtime_dependency('rails', '~> 4.0', '>= 4.0.0')
end
