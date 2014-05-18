require 'spec_helper'

describe Tag do

  before (:each) do
    @wiki0 = FactoryGirl.create(:wiki, :title => "Josephine")
    @wiki1 = FactoryGirl.create(:wiki, :title => "Foster")
    @tag0 = @wiki0.tags.first
    @tag1 = @wiki1.tags.first

  end

  it "should create a valid tag" do
    @tag0.should be_valid
  end

  it "should handle a wiki with no tags" do
    @wiki0.tags.destroy_all
    @wiki0.tags.count.should == 0
    @wiki0.should be_valid
  end
  
  it "should handle a wiki with a tag" do
    @wiki0.tags.count.should == 1
    @wiki0.should be_valid
  end
    
  it "should recognize a tag's wikis" do
    @tag0.wikis.count.should == 1
    @tag0.wikis.first.title.should == "Josephine"
  end
  
  it "should allow a tag to have multiple wikis" do
    @tag1.wikis << @wiki0 
    @tag1.wikis.count.should == 2
  end

end
