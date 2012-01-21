# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cruddler/version"

Gem::Specification.new do |s|
  s.name        = "cruddler"
  s.version     = Cruddler::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "lazy coders"
  s.email       = "info@provideal.net"
  s.homepage    = "http://github.com/provideal/cruddler"
  s.description = "quite lazy coders"
  s.authors     = ['Peter Horn', 'René Sprotte']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]
  s.rdoc_options  = ['--charset=UTF-8']


  s.add_runtime_dependency('rails', '> 3.1.0')
end
