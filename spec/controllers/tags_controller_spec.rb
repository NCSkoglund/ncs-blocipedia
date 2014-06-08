require 'spec_helper'

describe TagsController do

  before (:each) do
    @tag = FactoryGirl.create(:tag)
    @wiki = FactoryGirl.create(:wiki)
    @tag.wikis << @wiki
    # create a basic user
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'index'" do
    before (:each) do
      get :index
    end

    it "returns http success" do
      response.should be_success
    end

    it "renders the :index view" do
      response.should render_template :index
    end
    
    it "populates an array of tags" do
      assigns(:tags).should eq(Tag.visible_to(@user).uniq)
    end
  end

  describe "GET 'show'" do
    
    context "for a valid page" do
      before (:each) do
        get 'show', :id => @tag.id
      end

      it "returns http success" do
        response.should be_success
      end

      it "finds the right tag" do
        assigns(:tag).should == @tag   
      end

      it "assigns @wiki to the tag's wikis" do
        assigns(:wikis).should == @tag.wikis
      end
    end

    context "for an invalid page" do
      before (:each) do
        get 'show', :id => 0
      end

      it "has 404 status when wiki_id is not found" do
        response.status.should eq(404)
      end 

      it "renders 404 message when wiki_id is not found" do 
        response.body.should eq("404 Not Found")
      end
    end     
  end

##################  Where should these be located?  Actions grouped by user type within controllers.
  
  #   Guest User:
#Tags controller
# -I can see a list of all tags that contain public wikis on tags#index
# -I can see the public wikis associated with those tags, but not private
# -I can access a Tags#show screen 
# " a tag is publicly visible as long as it has at least one public wiki"
  # end=

# _____
#basic user
# -TAG:CULL TAKES A LONG TIME
# -I can see tags scoped for privacy
# -I cannot navigate to a tag#show if it has no public wikis associated

# _____
#premium
# -TAG:CULL TAKES A LONG TIME
# -I can see all tags
# -I can navigate to tags#show and see all associated wikis

# _____
#admin
# -TAG:CULL TAKES A LONG TIME
# -I can see all tags
# -I can navigate to tags#show and see all associated wikis


end
