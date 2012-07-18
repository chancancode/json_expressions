require 'spec_helper'
require 'json_expressions'
require 'json_expressions/rspec'

describe RSpec do
  it "includes JsonExpressions::RSpec::Matchers" do
    modules = ::RSpec.configuration.include_or_extend_modules
    modules.select! { |(mode,mod,_)| mode == :include }
    modules.map! { |(mode,mod,_)| mod }
    modules.should include(::JsonExpressions::RSpec::Matchers)
  end
end