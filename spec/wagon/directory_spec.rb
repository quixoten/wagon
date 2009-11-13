require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Wagon::Directory" do
  
  before(:each) do
    @directory = Wagon::Directory.new($user, $user.ward.directory_path, $user.ward)
  end
  
  it "should find the photo directory link" do
    @directory.instance_variable_get(:@url).should_not be_nil
    @directory.instance_variable_get(:@url).should match(%r{^/units/a/directory/photoprint})
  end
  
  it "should be able to generate a pdf" do
    lambda { @directory.to_pdf.render_file("./photo_directory.pdf") }.should_not raise_error
  end
  
  it "should parse out the households correctly" do
    @directory.households.should have_at_least(10).items
  end
  
end
