require 'spec_helper'

describe Wiki do

  before (:each) do
    @wiki = FactoryGirl.create(:wiki) 
  end

  it "should create a valid wiki" do
    @wiki.should be_valid
  end


  #Testing validation by regular expression 
  it "should accept a title if at least five characters including special characters" do
    @wiki.title = "'o' 1"
    @wiki.should be_valid
  end

  it "should accept a title greater than 5 characters" do  
    @wiki.title = "x x0xsf lja.psj  fpasd?!jf plasjdf<l>  "
    @wiki.should be_valid
  end

  it "should reject a title if less than five characters" do
      @wiki.title = "o.x  "
      @wiki.should_not be_valid
  end

  it "should reject a title if an empty string" do    
      @wiki.title = ""  
      @wiki.should_not be_valid
  end
  
  it "should reject a title if nil" do    
      @wiki.title = nil 
      @wiki.should_not be_valid
  end

  it "should reject edge cases with following whitespace" do
     @wiki.title = "x oo "
     @wiki.should_not be_valid
  end

  it "should reject edge cases with preceding whitespace" do
     @wiki.title = "    x"
     @wiki.should_not be_valid
  end

  it "should allow preceding and trailing whitespace as long as there are 5 valid characters" do
    @wiki.title = "    x x0x  "
    @wiki.should be_valid
  end



  it "should allow a description" do
    @wiki.description = "A new description"
    @wiki.should be_valid
  end

  it "should allow a description to be optional" do
    @wiki.description = ""
    @wiki.should be_valid
  end



  it "should accept a body if at least twenty characters including special characters" do
    @wiki.body = "0 abcde 89012 ?/ 789"
    @wiki.should be_valid
  end

  it "should reject a body if less than twenty characters" do
    @wiki.body = "0123456789012345678"
    @wiki.should_not be_valid
  end

  it "should reject a body if an empty string" do 
    @wiki.body = ""
    @wiki.should_not be_valid
  end

  it "should reject a body if nil" do
    @wiki.body = nil
    @wiki.should_not be_valid
  end



  # it "should be able to be set to public" do 
  #   @wiki.update_attribute(:public, true)
  #   @wiki.public.should be_true
  # end
  # it "should be able to be set to private" do
  #   @wiki.update_attribute(:public, false)
  #   @wiki.public.should be_false
  # " a tag is publicly visible as long as it has at least one public wiki"
  # end


  # pending "if private, it should have collaborators/contributor"
      # "collaborator:  an object matching a user_id with a wiki_id"
  #   it "public"
  #     "anyone can be a collaborator"
  #   it "@wiki.update_attribute(:public, false)"
  #     "a collaborator must have this wiki_id to view/edit"
  #     "a user has_many collaborations"
  #   it "if a user is a collaborator, they should have edit permissions"
  #     "create user, add as collaborator, can edit"
  #     "another user, not collaborator, cannot edit"
  #   it "a private wiki should be able to list its multiple collaborators"


  # pending "it should be able to be flagged for improvement"
  #   it "article successfully flagged"
  #      "wiki mark flag, wiki.flagged?.should be_true"
  #      "wiki no flag, wiki.flagged?.should be_false"
  # pending "it should be able to have a flag removed after improvement"
  #   it "article successfully unflagged"  
  #     "wiki flagged, remove flag, wiki.flagged?.should be_false"


  # pending "it should show the timestamp of its last update"
  #   it "wiki created, last modified timestamp, edit wiki, new last modified timestamp"


  it "should be able to be removed" do
    @wiki.destroy
    Wiki.all.should_not include(@wiki)
  end

  it "should remove itself from a tag's wikis upon deletion" do
    @tag = @wiki.tags.first
    @wiki2 = FactoryGirl.create(:wiki)
    @tag.wikis << @wiki2
    @tag.wikis.count.should == 2
    @wiki.destroy
    @tag.wikis.count.should ==1
  end

  it "should destroy a tag upon deletion if it is the only wiki belonging to that tag" do
    @wiki2 = FactoryGirl.create(:wiki)
    @wiki2.tags.count.should == 1
    t = @wiki2.tags.first
    t.wikis.count.should == 1
    @wiki2.destroy
    Tag.all.should_not include(t)
  end

end
