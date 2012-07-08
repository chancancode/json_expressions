guard 'minitest', :rubygems => true do
  watch(%r|^test/(.*/)?test_(.*)\.rb|)
  watch(%r{^lib/(.*/)?([^/]+)\.rb$}) { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r|^test/minitest_helper\.rb|) { "test" }
end