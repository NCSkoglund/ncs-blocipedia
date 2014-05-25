require 'spec_helper'

describe TagsController do

  before (:each) do
    @tag = FactoryGirl.create(:tag)
    @wiki = FactoryGirl.create(:wiki)
    @tag.wikis << @wiki
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

    it "populates an array of wikis" do
      assigns(:wikis).should eq(Wiki.all)
    end
    
    it "populates an array of tags" do
      assigns(:tags).should eq(Tag.all)
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
end
