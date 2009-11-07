require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Wagon" do
  
  before(:each) do
    @user = $user
  end
  
  it "should be connected" do
    @user.should_not be_nil
    @user.home_path.should_not be_nil
  end
  
end
