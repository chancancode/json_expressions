# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "json_expressions"
  s.version     = "0.7.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Godfrey Chan"]
  s.email       = ["godfreykfc@gmail.com"]
  s.homepage    = "https://github.com/chancancode/json_expressions"
  s.summary     = "JSON Expressions"
  s.description = "JSON matchmaking for all your API testing needs."

  s.required_rubygems_version = ">= 1.3.6"

  s.files        = Dir.glob("{lib,vendor}/**/*") + %w(README.md CHANGLOG.md LICENSE)
  s.require_path = 'lib'
end
