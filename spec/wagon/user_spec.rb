require 'spec_helper'

describe Wagon::User, :class do

  describe ".new" do
    before { VCR.insert_cassette :user }
    after { VCR.eject_cassette }

    it "needs to succeed with a valid username and password" do
      user = Wagon::User.new "username", "valid_password"
      user.must_be_instance_of Wagon::User
    end

    it "needs to fail with an invalid username or password" do
      proc {
        Wagon::User.new "username", "invalid_password"
      }.must_raise ArgumentError
    end
  end
end

# describe Wagon::User, :instance do
# 
#   subject { Wagon::User.new "username", "valid_password" }
#   let(:subject_cookies) { subject.instance_variable_get :@cookies }
# 
#   before { VCR.insert_cassette :user }
#   after { VCR.eject_cassette }
# 
#   describe "#wards" do
#     let(:wards) { subject.wards }
# 
#     it "needs to return an array of wards" do
#       wards.must_be_instance_of Array
#       wards.each do |ward|
#         ward.must_be_instance_of Wagon::Ward
#       end
#     end
# 
#     it "needs to return the correct number of items" do
#       wards.size.must_equal 3
#     end
#   end
# end
