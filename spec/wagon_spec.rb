require 'spec_helper'

describe Wagon do
  it "has a version number" do
    refute_nil Wagon::VERSION
  end

  describe "#connect" do
    it "delegates to Wagon::Agent.new" do
      connection = Object.new

      Wagon::Hub.stub :new, connection do
        Wagon.connect("name", "pass").must_be_same_as connection
      end
    end
  end
end
