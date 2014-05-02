require 'spec_helper'

describe Tag do

  before (:each) do
    @tag0 = FactoryGirl.create(:tag) 
    @wiki1 = FactoryGirl.create(:wiki) 
  end

  it "should create a valid tag" do
    @tag0.should be_valid
  end

  it "should associate a tag with a wiki" do
  end

  it "should allow a wiki to have zero or more tags" do
  end

  it "should allow a tag to have one or more wikis" do
  end  

end
