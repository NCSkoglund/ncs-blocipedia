require 'spec_helper'

describe Tag do

  before (:each) do

    @josephine_wiki = FactoryGirl.create(:wiki, :title => "Josephine")
    @foster_wiki = FactoryGirl.create(:wiki, :title => "Foster")

    @jesamine_tag = @josephine_wiki.tags.first
    @folder_tag = @foster_wiki.tags.first
    
    # create a tag with multiple associated wikis
    @folder_tag.wikis << @josephine_wiki 
  end

  it "creates a valid tag" do
    @jesamine_tag.should be_valid
  end

  describe "wiki-tag associations" do 
    
    it "recognizes a tag's wikis" do
      @jesamine_tag.wikis.first.title.should == "Josephine"
    end

    it "allows a tag to have one wiki" do
      @jesamine_tag.wikis.count.should == 1
      @jesamine_tag.should be_valid
    end

    it "allows a tag to have multiple wikis" do
      @folder_tag.wikis.count.should == 2
      @folder_tag.should be_valid
    end  
    
  end 

  describe "terminator callback testing" do
    before (:each) do
      @jesamine_tag.wikis.count.should == 1
      @folder_tag.wikis.count.should == 2
      
      @jesamine_tag.destroy
      @folder_tag.destroy
    end

    it "destroys the tag if it only has one wiki association" do
      Tag.all.should_not include(@jesamine_tag)
    end

    it "does not destroy the tag if it has more than one wiki association" do
      Tag.all.should include(@folder_tag)
    end
  end


  #validation testing for tags?  
  #wiki presence validation?

end
