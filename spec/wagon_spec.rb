require 'spec_helper'

describe Wagon do
  it "has a version number" do
    Wagon::VERSION.must_match /\d+\.\d+\.\d+/
  end
end
