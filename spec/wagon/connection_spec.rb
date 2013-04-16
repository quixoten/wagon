require 'spec_helper'

describe Wagon::Connection do
  describe ".new" do
    before { VCR.insert_cassette :connection }
    after { VCR.eject_cassette }

    it "succeeds with a valid username and password" do
      connection = Wagon::Connection.new("username", "valid_password")
      connection.must_be_instance_of Wagon::Connection
    end

    it "fails with an invalid username or password" do
      proc {
        Wagon::Connection.new("username", "invalid_password")
      }.must_raise Wagon::InvalidCredentials
    end
  end

  describe "#post" do
    it "needs to be tested" do
      skip
    end
  end

  describe "#get" do
    it "needs to be tested" do
      skip
    end
  end
end
