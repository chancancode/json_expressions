require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'

task :default => [:test, :spec]

desc 'Run all test'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

desc 'Run all spec'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = ['--color', '--backtrace']
end