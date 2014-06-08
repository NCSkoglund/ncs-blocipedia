require 'spec_helper'

describe WikisController do

  before (:each) do
    @wiki = FactoryGirl.create(:wiki)
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

    it "populates an array of wikis" do
      assigns(:wikis).should eq(Wiki.visible_to(@user))
    end
    
    it "populates an array of tags" do
      assigns(:tags).should eq(Tag.all)
    end
  end

  describe "GET 'show'" do
    context "for a valid page" do
      before (:each) do
        @tag = FactoryGirl.create(:tag)
        @wiki.tags << @tag
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

      it "assigns @tags to the wiki's tags" do
        assigns(:tags).should == @wiki.tags
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

    it "assigns a new Tag to @tag" do
      assigns(:tag).should be_a_new(Tag)
    end
  end

  describe "POST 'create'" do

    context "with valid params" do
      
      before (:each) do
        @attr = FactoryGirl.attributes_for(:wiki)
        @tag = FactoryGirl.create(:tag)
        post :create, wiki: @attr, tags: @tag
      end

      it "adds one Wiki to the total Wiki count" do
        expect {
          post :create, wiki: @attr       
        }.to change(Wiki, :count).by(1)
      end

      it "assigns a newly created Wiki as @wiki" do
        expect(assigns(:wiki)).to be_a(Wiki)
      end

      it "persists the newly created Wiki" do
        expect(assigns(:wiki)).to be_persisted 
      end

      it "flashes a success message upon save" do
        flash[:notice].should eq("Wiki was saved successfully.")
      end

      it "redirects to the new wiki" do
        # the newest wiki is added to the front of the collection, not the end
        response.should redirect_to Wiki.first
      end
      
      it "assigns the given tag to the wiki" do
        Wiki.first.tags.first.should eq(@tag)
      end
      
      it "only sets the given number of tags in the wiki" do
        Wiki.first.tags.length.should eq(1)
      end
    end

    context "with invalid params" do
      before (:each) do
        @attr = FactoryGirl.attributes_for(:wiki, :title => nil)
        post :create, wiki: @attr
      end

      it "does not change the total Wiki count" do 
        expect{
          post :create, wiki: @attr
        }.to_not change(Wiki, :count)
      end

      it "assigns the newly created Wiki as @wiki" do
        expect(assigns(:wiki)).to be_a(Wiki)
      end

      it "does not persist the newly created Wiki" do
        expect(assigns(:wiki)).to_not be_persisted  
      end

      it "flashes an error message" do
        flash[:error].should eq("An error occurred in the create method, please try again.")
      end

      it "re-renders the 'new' template" do
        response.should render_template(:new)
      end

      it "resets @tag to a new tag object" do 
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

    it "assigns the given wiki's tags to @tags" do
      assigns(:tags).should == @wiki.tags
    end
 
    it "assigns @tag to a new tag object" do
      expect(assigns(:tag)).to be_a_new(Tag)
    end
  end


  describe "PUT 'update'" do

    context "with valid params" do

      before (:each) do
        @previous_tag = @wiki.tags.last
        @wiki.tags.count.should eq(1)

        @new_attr = FactoryGirl.attributes_for(:wiki, :title => 'xoxox')
        put :update, id: @wiki, wiki: @new_attr, tags: @previous_tag
        @wiki.reload
      end

      it "locates the requested wiki" do
        assigns(:wiki).should eq(@wiki)
      end

      it "assigns new attributes to @wiki" do
        @wiki.title.should eq("xoxox")
      end

      it "removes old attributes from @wiki" do
        @wiki.title.should_not eq("MyString")
      end

      it "redirects to the updated wiki" do 
        response.should redirect_to @wiki
      end

      it "flashes a success message if saved" do
        flash[:notice].should eq("Wiki was updated.")
      end
      
      describe "updates tags associations with valid data" do
        
        before (:each) do
          @wiki.tags.last.should eq(@previous_tag)
          @wiki.tags.count.should eq(1)
          
          @new_tag = FactoryGirl.create(:tag)
          put :update, id: @wiki, wiki: @new_attr, tags: @new_tag
          @wiki.reload
        end

        it "removes preexisting tags" do 
          @wiki.tags.should_not include(@previous_tag)
        end

        it "assigns new tags" do
          @wiki.tags.first.should eq(@new_tag)
        end

        it "assigns the given quantity of new tags" do
          @wiki.tags.count.should eq(1)
        end

        it "can assign multiple tags" do
          put :update, id: @wiki, wiki: @new_attr, tags: [@new_tag, @previous_tag]
          @wiki.reload
          @wiki.tags.count.should eq(2)
        end

        it "can assign zero tags" do
          put :update, id: @wiki, wiki: @new_attr
          @wiki.reload
          @wiki.tags.count.should eq(0)
        end
      end
    end

    context "with invalid params" do
      before (:each) do
        @previous_tag = @wiki.tags.last
        @wiki.tags.count.should eq(1)

        @new_attr = FactoryGirl.attributes_for(:wiki, :title => 'xox')
        put :update, id: @wiki, wiki: @new_attr
        @wiki.reload
      end

      it "locates the requested wiki" do
        assigns(:wiki).should eq(@wiki)
      end
      
      it "does not assign the new attributes" do
        @wiki.title.should_not eq("xox")
      end

      it "does not overwrite the preexisting attributes" do
        @wiki.title.should eq("MyString")
      end

      it "renders the edit template" do
        response.should render_template(:edit)
      end

      it "flashes an error message" do
        flash[:error].should eq("There was an error updating the wiki.  Please try again.")
      end

      describe "does not update tag associations with invalid data" do

        it "does not overwrite the preexisting tags" do
          @wiki.tags.first.should eq(@previous_tag)
        end

        it "does not change the number of tags" do
          @wiki.tags.count.should eq(1)
        end 
      end
    end
  end
 
  describe "DELETE 'destroy'" do

    describe "destroy wiki object" do 
      before (:each) do
        delete :destroy, id: @wiki 
      end

      it "deletes the wiki" do
        Wiki.all.should_not include(@wiki)
      end

      it "redirects to wikis#index" do
        response.should redirect_to wikis_path
      end

      it "removes one Wiki from the total Wiki count" do
        # test removal of a different wiki to avoid testing conflict
        @attr = FactoryGirl.create(:wiki)
        expect {
          delete :destroy, id: @attr      
        }.to change(Wiki, :count).by(-1)
      end
    end

    describe "destroy appropriate associated tags" do
      before (:each) do
        #create a tag with one wiki and another with two wikis
       
        @one_wiki_tag = @wiki.tags.first
        @second_wiki = FactoryGirl.create(:wiki)
        @two_wiki_tag = @second_wiki.tags.first
        @wiki.tags << @two_wiki_tag

        @wiki.tags.count.should eq(2)
        @one_wiki_tag.wikis.count.should eq(1)
        @two_wiki_tag.wikis.count.should eq(2)

        delete :destroy, id: @wiki 
      end

      it "calls destroy on its associated tags when destroyed" do
        Tag.all.should_not include(@one_wiki_tag)
      end

      it "does not destroy associated tags that still belong to another wiki" do
        Tag.all.should include(@two_wiki_tag)
      end
    end
  end

##################  Where should these be located?  Actions grouped by user type within controllers.
  
  #Guest user permissions
  # Wikis controller
# Rescue from Pundit :user_not_authorized  —> this should fit into user type testing
# -I can see an index of wikis that are set to private: false
# -I cannot see a private wiki through direct navigation 
# -I can see a public wiki 
# -I cannot edit a public wiki 
# -I cannot edit a private wiki
# -I cannot delete a public wiki 
# -I cannot delete a private wiki
# -I cannot navigate to the new wiki form
# -I can see a list of tags containing public wikis on the side of wikis#index

# As a Basic User:
# -It displays Wikis#index upon sign in
# -I can see an index of wikis that are set to private: false
# -I can see the New Wiki link from Wikis#Index
# -I can see the New Wiki form without the private checkbox
# -I can create a new public wiki, add preexisting tags and create one new tag
# -I cannot view a private wiki 
# -I can see the edit wiki link inside of Wiki#Show
# -I can see the edit wiki form for a public wiki without the private checkbox
# -I can edit a public wikis fields and tags
# -I can see the delete Wiki button from Wiki#Show
# -I can delete a public wiki

# PREMIUM USER
# -It displays Wikis#index upon sign in
# -I can see an index of all wikis
# -I can see the New Wiki link from Wikis#Index
# -I can see the New Wiki form with the private checkbox
# -I can create a new private wiki, add preexisting tags and create one new tag
# -I can view a private wiki 
# -I can see the edit wiki link inside of Wiki#Show
# -I can see the edit wiki form for a private wiki with the private checkbox
# -I can edit a private wikis fields and tags
# -I can see the delete Wiki button from Wiki#Show
# -I can delete a private wiki

# ADMIN USER’
# -It displays Wikis#index upon sign in
# -I can see an index of all wikis
# -I can see the New Wiki link from Wikis#Index
# -I can see the New Wiki form with the private checkbox
# -I can create a new private wiki, add preexisting tags and create one new tag
# -I can view a private wiki 
# -I can see the edit wiki link inside of Wiki#Show
# -I can see the edit wiki form for a private wiki with the private checkbox
# -I can edit a private wikis fields and tags
# -I can see the delete Wiki button from Wiki#Show
# -I can delete a private wiki




end
