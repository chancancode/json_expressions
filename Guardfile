guard 'minitest', :rubygems => true do
  watch(%r|^test/(.*/)?test_(.*)\.rb|)
  watch(%r{^lib/(.*/)?([^/]+)\.rb$}) { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r|^test/minitest_helper\.rb|) { "test" }
end

guard 'rspec' do
  watch(%r|^spec/(.*/)?(.*)_spec\.rb|)
  watch(%r{^lib/(.*/)?([^/]+)\.rb$}) { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r|^spec/spec_helper\.rb|) { "spec" }
end