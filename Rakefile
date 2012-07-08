require 'rake'
require 'rake/testtask'

task :default => [:test]

desc "Run all test"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*/test_*.rb']
  t.verbose = true
  t.warning = true
end