require 'spec_helper'

describe Wagon::Request::Login do
  before { VCR.insert_cassette :login_request }
  after { VCR.eject_cassette }

  it "needs to succeed with a valid username and password" do
    req = Wagon::Request::Login.new "username", "valid_password"
    req.send
  end

  it "needs to fail with an invalid username or password" do
    proc {
      req = Wagon::Request::Login.new "username", "invalid_password"
      req.send
    }.must_raise ArgumentError
  end
end
