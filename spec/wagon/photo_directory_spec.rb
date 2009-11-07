require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Wagon::PhotoDirectory" do
  
  before(:each) do
    @page = Wagon::PhotoDirectory.new($user, $user.ward.directory.photo_directory_path)
  end
  
  it "should parse out the households correctly" do
    @page.households.should have_at_least(10).items
    puts @page.households.join("\n")
  end
  
end
