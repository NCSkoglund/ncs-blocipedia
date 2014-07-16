require 'spec_helper'

describe TagsController do

  before (:each) do
    # create a basic user
    @user = FactoryGirl.create(:user)
    sign_in @user

    @wiki = FactoryGirl.create(:wiki)
    @tag = FactoryGirl.create(:tag)
    @wiki.tags << @tag

    @private_wiki = FactoryGirl.create(:wiki, private: true)
    @private_tag = FactoryGirl.create(:tag)
    @private_wiki.tags << @private_tag

    @private_wiki2 = FactoryGirl.create(:wiki, private: true)
    @private_tag2 = FactoryGirl.create(:tag)
    @private_wiki2.tags << @private_tag2
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
      # given a basic user
      assigns(:tags)["t"].should eq(@wiki.tags)
    end

    it "groups tags by first letter" do
      @tag1 = @wiki.tags.first 
      @tag2 = @wiki.tags.last
      @wiki.tags.count.should eq(2)

      @tag_n = FactoryGirl.create(:tag, tag: "nosferatu")
      @wiki.tags << @tag_n

      get :index
      assigns(:tags)["t"].should eq([@tag1, @tag2])
      assigns(:tags)["n"].should eq([@tag_n])
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

      it "renders public/404.html" do
        response.should render_template(:file => "#{Rails.root}/public/404.html")
      end
    end     
  end

 describe "user level permissions regarding tags_controller" do

    context "as a basic user" do

      it "can see an index of tags that belong to public wikis" do
        get :index
        assigns(:tags)["t"].should include(@tag)
      end

      it "cannot see an index of tags that belong to private wikis" do
        get :index
        assigns(:tags).should_not include(@private_tag)
      end

      it "can show a tag but differentiate between the privacy of its associated wikis" do 
        @private_wiki.tags << @tag
        get :index
        assigns(:tags)["t"].should include(@tag)
        assigns(:wikis).should_not include(@private_wiki)      
      end

      it "can navigate to the show page of a tag that belongs to a public wiki" do 
        get :show, id: @tag.id
        response.should be_success
      end

      it "cannot navigate to the show page of a tag that belongs to a private wiki" do
        get :show, id: @private_tag.id
        response.should_not be_success
      end

    end 

    context "as a premium user" do

      before(:each) do
        @user.update_attribute(:level, "premium")
        @private_wiki2.users << @user
      end

      it "can see an index of tags that belong to public wikis" do
        get :index
        assigns(:tags)["t"].should include(@tag)
      end

      it "can see an index of tags that belong to collaborative private wikis" do
        get :index
        assigns(:tags)["t"].should include(@private_tag2)
      end

      it "cannot see an index of tags that belong to non-collaborative private wikis " do
        get :index
        assigns(:tags).should_not include(@private_tag)
      end

      it "can show a tag but differentiate between the privacy of its associated wikis" do 
        @private_wiki.tags << @tag
        get :index
        assigns(:tags)["t"].should include(@tag)
        assigns(:wikis).should_not include(@private_wiki)      
      end

      it "can navigate to the show page of a tag that belongs to a public wiki" do
        get :show, id: @tag.id
        response.should be_success
      end

      it "can navigate to the show page of a tag that belongs to a collaborative private wiki" do
        get :show, id: @private_tag2.id
        response.should be_success
      end

      it "cannot navigate to the show page of a tag that belongs to a non-collaborative private wiki" do
        get :show, id: @private_tag.id
        response.should_not be_success
      end

    end

    context "as an admin user" do

      before(:each) do
        @user.update_attribute(:level, "admin")
        @private_wiki2.users << @user
      end 

      it "can see an index of tags that belong to public wikis" do
        get :index
        assigns(:tags).should include(@tag)
      end

      it "can see an index of tags that belong to collaborative private wikis" do
        get :index
        assigns(:tags).should include(@private_tag2)
      end

      it "can see an index of tags that belong to non-collaborative private wikis " do
        get :index
        assigns(:tags).should include(@private_tag)
      end

      it "can show a tag and all associated wikis regardless of privacy" do 
        @private_wiki.tags << @tag
        get :index
        assigns(:tags).should include(@tag)
        assigns(:wikis).should include(@private_wiki)      
      end
      
      it "can navigate to the show page of a tag that belongs to a public wiki" do
        get :show, id: @tag.id
        response.should be_success
      end

      it "can navigate to the show page of a tag that belongs to a collaborative private wiki" do
        get :show, id: @private_tag2.id
        response.should be_success
      end

      it "can navigate to the show page of a tag that belongs to a non-collaborative private wiki" do
        get :show, id: @private_tag.id
        response.should be_success
      end

    end

    context "as a guest user" do

      before (:each) do
        @private_wiki2.users << @user 
        sign_out @user
      end
      
      it "can see an index of tags that belong to public wikis" do
        get :index
        assigns(:tags)["t"].should include(@tag)
      end

      it "cannot see an index of tags that belong to collaborative private wikis" do
        get :index
        assigns(:tags).should_not include(@private_tag2)
      end

      it "cannot see an index of tags that belong to non-collaborative private wikis " do
        get :index
        assigns(:tags).should_not include(@private_tag)
      end

      it "can show a tag but differentiate between the privacy of its associated wikis" do 
        @private_wiki.tags << @tag
        get :index
        assigns(:tags)["t"].should include(@tag)
        assigns(:wikis).should_not include(@private_wiki)      
      end

      it "can navigate to the show page of a tag that belongs to a public wiki" do
        get :show, id: @tag.id
        response.should be_success
      end

      it "cannot navigate to the show page of a tag that belongs to a collaborative private wiki" do
        get :show, id: @private_tag2.id
        response.should_not be_success
      end

      it "cannot navigate to the show page of a tag that belongs to a non-collaborative private wiki" do
        get :show, id: @private_tag.id
        response.should_not be_success
      end
    end
  end 
end
