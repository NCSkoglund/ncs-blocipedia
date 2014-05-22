require 'spec_helper'

describe Tag do

  before (:each) do
    @wiki0 = FactoryGirl.create(:wiki, :title => "Josephine")
    @wiki1 = FactoryGirl.create(:wiki, :title => "Foster")
    @tag0 = @wiki0.tags.first
    @tag1 = @wiki1.tags.first

  end

  it "creates a valid tag" do
    @tag0.should be_valid
  end

  it "handles a wiki with no tags" do
    @wiki0.tags.destroy_all
    @wiki0.tags.count.should == 0
    @wiki0.should be_valid
  end
  
  it "handles a wiki with a tag" do
    @wiki0.tags.count.should == 1
    @wiki0.should be_valid
  end
    
  it "recognizes a tag's wikis" do
    @tag0.wikis.count.should == 1
    @tag0.wikis.first.title.should == "Josephine"
  end
  
  it "allows a tag to have multiple wikis" do
    @tag1.wikis << @wiki0 
    @tag1.wikis.count.should == 2
  end

end
