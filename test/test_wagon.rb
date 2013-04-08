require 'minitest_helper'

describe Wagon do
  it "has a version number" do
    refute_nil Wagon::VERSION
  end

  describe "#connect" do
    it "delegates to Wagon::Agent.new" do
      agent = Object.new

      Wagon::Agent.stub :new, agent do
        Wagon.connect("name", "pass").must_be_same_as agent
      end
    end
  end
end
