# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "json_tester"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Godfrey Chan"]
  s.email       = ["godfreykfc@gmail.com"]
  s.homepage    = "https://github.com/chancancode/json_tester"
  s.summary     = "JSON Tester"
  s.description = "Test whether a JSON matches a given structure."

  s.required_rubygems_version = ">= 1.3.6"

  s.files        = Dir.glob("{lib,vendor}/**/*") + %w(README.md)
  s.require_path = 'lib'
end
