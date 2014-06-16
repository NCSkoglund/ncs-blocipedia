require 'spec_helper'

describe Wiki do

  before (:each) do
    @wiki = FactoryGirl.create(:wiki) 
  end

  it "creates a valid wiki" do
    @wiki.should be_valid
  end

  describe "testing validations by regular expression" do 

    it "accepts a title if at least five characters including special characters" do
      @wiki.title = "'o' 1"
      @wiki.should be_valid
    end

    it "accepts a title greater than 5 characters" do  
      @wiki.title = "x x0xsf lja.psj  fpasd?!jf plasjdf<l>  "
      @wiki.should be_valid
    end

    it "rejects a title if less than five characters" do
        @wiki.title = "o.x  "
        @wiki.should_not be_valid
    end

    it "rejects a title if an empty string" do    
        @wiki.title = ""  
        @wiki.should_not be_valid
    end
    
    it "rejects a title if nil" do    
        @wiki.title = nil 
        @wiki.should_not be_valid
    end

    it "rejects edge cases with following whitespace" do
       @wiki.title = "x oo "
       @wiki.should_not be_valid
    end

    it "rejects edge cases with preceding whitespace" do
       @wiki.title = "    x"
       @wiki.should_not be_valid
    end

    it "allows preceding and trailing whitespace as long as there are 5 valid characters" do
      @wiki.title = "    x x0x  "
      @wiki.should be_valid
    end

    it "allows a description" do
      @wiki.description = "A new description"
      @wiki.should be_valid
    end

    it "allows a description to be optional" do
      @wiki.description = ""
      @wiki.should be_valid
    end

    it "accepts a body if at least twenty characters including special characters" do
      @wiki.body = "0 abcde 89012 ?/ 789"
      @wiki.should be_valid
    end

    it "rejects a body if less than twenty characters" do
      @wiki.body = "0123456789012345678"
      @wiki.should_not be_valid
    end

    it "rejects a body if an empty string" do 
      @wiki.body = ""
      @wiki.should_not be_valid
    end

    it "rejects a body if nil" do
      @wiki.body = nil
      @wiki.should_not be_valid
    end
  end

  describe "public-private settings" do

    it "can be set to private" do 
      @wiki.update_attribute(:private, 1)
      @wiki.private.should be_true
    end

    it "can be set to public" do
      @wiki.update_attribute(:private, 0)
      @wiki.private.should be_false
    end

    it "sets an empty private field to false" do
      @wiki.private = ""
      @wiki.private.should be_false
    end

    it "sets a nil private field to false" do
      @wiki.private = nil
      @wiki.private.should be_false
    end

    it "has an owner" do
      @user = FactoryGirl.create(:user)
      @wiki.update_attribute(:owner, @user)
      @wiki.owner.should eq(@user)
    end
  end

  describe "collaborator settings" do 
 
    before (:each) do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @wiki.users << @user
    end

    it "handles a wiki with one collaborator" do
      @wiki.users.count.should eq(1)
      @wiki.should be_valid
    end

    it "handles a wiki with multiple collaborators" do
      @wiki.users << @user2
      @wiki.users.count.should eq(2)
      @wiki.should be_valid
    end

    it "handles a wiki with no collaborators" do
      @wiki.users.destroy_all
      @wiki.users.count.should eq(0)
      @wiki.should be_valid
    end 
  end

  describe "wiki-tag associations" do 
    before (:each) do
      @tag1 = FactoryGirl.create(:tag)
    end

    it "handles a wiki with one tag" do
      @wiki.tags.count.should eq(1)
      @wiki.should be_valid
    end

    it "handles a wiki with multiple tags" do
      @wiki.tags << @tag1
      @wiki.tags.count.should eq(2)
      @wiki.should be_valid
    end

    it "handles a wiki with no tags" do
      @wiki.tags.destroy_all
      @wiki.tags.count.should eq(0)
      @wiki.should be_valid
    end 
  end

  # pending "it should be able to be flagged for improvement"
  #   it "article successfully flagged"
  #      "wiki mark flag, wiki.flagged?.should be_true"
  #      "wiki no flag, wiki.flagged?.should be_false"
  # pending "it should be able to have a flag removed after improvement"
  #   it "article successfully unflagged"  
  #     "wiki flagged, remove flag, wiki.flagged?.should be_false"
end
