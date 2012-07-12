require 'spec_helper'
require 'json_expressions'
require 'json_expressions/rspec'

describe RSpec do
  it "includes JsonExpressions::RSpec::Matchers" do
    # TODO actually verify this.
    # For now this spec verifies the spec helper file loads without errors
    true.should be_true
  end
end