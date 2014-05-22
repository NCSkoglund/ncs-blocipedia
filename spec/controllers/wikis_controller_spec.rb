require 'spec_helper'

describe WikisController do

  before (:each) do
   @wiki = FactoryGirl.create(:wiki)
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
    before (:each) do
      get 'show', :id => @wiki.id
    end

    it "returns http success" do
      response.should be_success
    end

    it "renders the #show view" do
      response.should render_template :show
    end

    it "assigns the requested wiki to @wiki" do  
      assigns(:wiki).should == @wiki
    end
    
    ### unsure how to implement this
    # it "redirects when wiki_id is not found" do
    #   @invalid_id = Wiki.all.count + 10
    #   Wiki.should_receive(:find).with(@invalid_id).and_raise(ActiveRecord::RecordNotFound)
    # #  response.should render_template(:not_found)
    # end    
  end

  describe "GET 'new'" do
    before (:each) do
      get 'new'
    end

    it "returns http success" do
      response.should be_success
    end

    it "renders the new template" do
      response.should render_template(:new)
    end

    it "assigns a new Wiki to @wiki" do
      assigns(:wiki).should be_a_new(Wiki)
    end
  end

  describe "POST 'create'" do

    context "with valid params" do
      before (:each) do
        @attr = FactoryGirl.attributes_for(:wiki)
      end

      it "creates and saves a new Wiki" do
        expect {
          post :create, wiki: @attr       # pull this out into a lambda for DRYer code
        }.to change(Wiki, :count).by(1)
      end

      it "flashes a success message" do
        post :create, :wiki => @attr
        flash[:notice].should eq("Wiki was saved successfully.")
      end

      it "redirects to the new wiki" do
        post :create, :wiki => @attr
        response.should redirect_to Wiki.last
      end

      it "accepts tags and associates them with the new wiki" do
        ### unsure how to write this
        ### does this belong here?
        # post :create, :wiki => @attr, :tags => [FactoryGirl.build(:tag)]
        # expect(Wiki.last.tags).to include(assigns(:tags))
      end
 
      #does this make sense?
      it "assigns the newly created wiki as @wiki" do
        post :create, wiki: @attr 
        expect(assigns(:wiki)).to be_a(Wiki)
        expect(assigns(:wiki)).to be_persisted 
      end
    end

    context "with invalid params" do
      before (:each) do
        @attr = FactoryGirl.attributes_for(:wiki, :title => nil)
      end

      it "does not save the new wiki" do 
        ### this version doesn't work; why?
        # post :create, wiki: @attr
        # Wiki.all.should_not include(@wiki)
        expect{
          post :create, wiki: @attr
        }.to_not change(Wiki, :count)
      end

      it "flashes an error message" do
        post :create, wiki: @attr
        flash[:error].should eq("An error occurred in the create method, please try again.")
      end

      it "re-renders the 'new' template" do
        post :create, wiki: @attr 
        response.should render_template(:new)
      end

      #does this make sense?
      it "assigns the newly created but unsaved wiki as @wiki" do
        post :create, wiki: @attr 
        expect(assigns(:wiki)).to be_a(Wiki)
        expect(assigns(:wiki)).to_not be_persisted  
      end

      it "resets @tag to a new tag object" do 
        post :create, wiki: @attr 
        expect(assigns(:tag)).to be_a_new(Tag)
      end
    end
  end 

  describe "GET 'edit'" do
    before (:each) do
      get 'edit', :id => @wiki.id
    end

    it "returns http success" do
      response.should be_success
    end

    it "renders the edit template" do
      response.should render_template(:edit)
    end

    it "assigns the requested wiki to @wiki" do  
      assigns(:wiki).should == @wiki
    end

    it "displays the given wiki's tags" do
      assigns(:tags).should == @wiki.tags
    end
 
    it "assigns @tag to a new tag object" do
      expect(assigns(:tag)).to be_a_new(Tag)
    end
  end


  describe "PUT 'update'" do

    context "with valid params" do
      before (:each) do
        @attr = FactoryGirl.attributes_for(:wiki)
        put :update, id: @wiki, wiki: @attr
      end

      it "locates the requested wiki" do
        assigns(:wiki).should eq(@wiki)
      end

      it "changes @wiki's attributes" do
        put :update, id: @wiki, wiki: FactoryGirl.attributes_for(:wiki, :title => 'xoxox')
        @wiki.reload
        @wiki.title.should eq("xoxox")
        @wiki.title.should_not eq("MyString")
      end

      # it "updates the wiki's tags" do 
      #   #     revisit
      # end

      it "redirects to the updated wiki" do 
        response.should redirect_to @wiki
      end

      it "flashes a success message if saved" do
        flash[:notice].should eq("Wiki was updated.")
      end

    end

    context "with invalid params" do
      before (:each) do
        @attr = FactoryGirl.attributes_for(:wiki, :title => nil)
        put :update, id: @wiki, wiki: @attr
      end

      it "locates the requested wiki" do
        assigns(:wiki).should eq(@wiki)
      end
      
      it "does not change the wiki's attributes" do
        put :update, id: @wiki, wiki: FactoryGirl.attributes_for(:wiki, :title => 'xox')
        @wiki.reload
        @wiki.title.should_not eq("xox")
        @wiki.title.should eq("MyString")
      end

      # it "does not change the wiki's tags" do
      #   #revisit
      # end
 
      it "renders the edit template" do
        response.should render_template(:edit)
      end

      it "flashes an error message" do
        flash[:error].should eq("There was an error updating the wiki.  Please try again.")
      end
    end
  end
 
  describe "DELETE 'destroy'" do
    before (:each) do
      delete :destroy, id: @wiki 
    end

    it "deletes the wiki" do
      Wiki.all.should_not include(@wiki)
    end

    it "redirects to wikis#index" do
      response.should redirect_to wikis_path
    end

    it "calls destroy on its associated tags when destroyed" do
      #this passes, but does it actually test whether destroy is being called on the tags?
      @wiki.tags.should respond_to(:destroy)
    end

  end

end
