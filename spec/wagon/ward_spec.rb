require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Wagon::Ward" do
  
  before(:each) do
    @page = Wagon::Ward.new($user, $user.home_path)
  end
  
  it "should have a name" do
    @page.name.to_s.should_not be_empty
  end
  
  it "should find the directory link" do
    @page.directory_path.should_not be_nil
    @page.directory_path.should match(%r{^/units/a/directory})
  end
  
end
