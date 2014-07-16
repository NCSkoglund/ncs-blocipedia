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
      # to_a overrides paginate
      assigns(:wikis).to_a.should eq(@user.visible_wikis.to_a)
    end
    
    it "populates an array of tags" do
      #given a basic user
      assigns(:tags).should eq(@wiki.tags)
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

      it "renders public/404.html" do
        response.should render_template(:file => "#{Rails.root}/public/404.html")
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

      it "adds the new wiki to the collection of Wikis" do
        Wiki.all.should include(assigns(:wiki))
      end

      it "redirects to the new wiki" do
        response.should redirect_to assigns(:wiki)
      end
      
      it "assigns the given tag to the wiki" do
        assigns(:wiki).tags.first.should eq(@tag)
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

  describe "user level permissions regarding tags_controller" do
    
    before (:each) do
        @private_wiki = FactoryGirl.create(:wiki, private: true)
      end

    context "as a basic user" do

      it "populates an array of wikis that are visible to the current user" do
        # to_a overrides paginate
        get :index
        assigns(:wikis).to_a.should eq(@user.visible_wikis.to_a)
      end

      it "does not include private wikis" do
        get :index
        assigns(:wikis).should_not include(@private_wiki)
      end

      it "can view a public wiki" do
        get :show, :id => @wiki.id
        response.should be_success
      end

      it "cannot view a private wiki" do
        get :show, :id => @private_wiki.id
        response.should_not be_success
      end

      it "can navigate to the new wiki form" do
        get :new
        response.should be_success
      end

      it "can navigate to the edit wiki form for a public wiki" do
        get :edit, :id => @wiki.id
        response.should be_success
      end

      it "cannot navigate to the edit wiki form for a private wiki" do
        get :edit, :id => @private_wiki.id
        response.should_not be_success
      end

      it "can delete a public wiki" do
        delete :destroy, id: @wiki
        Wiki.all.should_not include(@wiki)
      end

      it "cannot delete a private wiki" do 
        delete :destroy, id: @private_wiki
        Wiki.all.should include(@private_wiki)
      end

      describe "GET 'index' with relation to tag privacy given a basic user" do 

        before (:each) do
          @tag = FactoryGirl.create(:tag)
          @wiki.tags << @tag

          @private_wiki = FactoryGirl.create(:wiki, private: true)
          @private_tag = FactoryGirl.create(:tag)
          @private_wiki.tags << @private_tag
          
          # @tag is shared between a public and a private wiki
          @private_wiki.tags << @tag
          # #private_tag belongs exclusively to a private wiki
          get :index
        end
       
        it "populates an array of tags including those tags belonging to both public and private wikis" do  
          assigns(:tags).should include(@tag)
        end

        it "populates an array of tags excluding those tags belonging exclusively to private wikis" do
          assigns(:tags).should_not include(@private_tag)
        end
      end
    end

    context "as a premium user" do

      before (:each) do 
        @user.update_attribute(:level, "premium")
        @private_wiki2 = FactoryGirl.create(:wiki, private: true)
        @private_wiki2.users << @user
      end

      it "populates an array of wikis that are visible to the current user" do
        # to_a overrides paginate
        get :index
        assigns(:wikis).to_a.should eq(@user.visible_wikis.to_a)
      end

      it "includes collaborative private wikis" do
        get :index
        assigns(:wikis).should include(@private_wiki2)
      end

      it "does not include non-collaborative private wikis" do
        get :index
        assigns(:wikis).should_not include(@private_wiki)
      end

      it "can view a public wiki" do
        get :show, :id => @wiki.id
        response.should be_success
      end

      it "can view a collaborative private wiki" do
        get :show, :id => @private_wiki2
        response.should be_success
      end

      it "cannot view a non-collaborative private wiki" do
        get :show, :id => @private_wiki.id
        response.should_not be_success
      end

      it "can navigate to the new wiki form" do
        get :new
        response.should be_success
      end

      it "can navigate to the edit wiki form for a public wiki" do
        get :edit, :id => @wiki.id
        response.should be_success
      end

      it "can navigate to the edit wiki form for a collaborative private wiki" do
        get :edit, :id => @private_wiki2.id
        response.should be_success
      end

      it "cannot navigate to the edit wiki form for a non-collaborative private wiki" do
        get :edit, :id => @private_wiki.id
        response.should_not be_success
      end

      it "can delete a public wiki" do
        delete :destroy, id: @wiki
        Wiki.all.should_not include(@wiki)
      end

      it "can delete a collaborative private wiki" do 
        delete :destroy, id: @private_wiki2
        Wiki.all.should_not include(@private_wiki2)
      end

      it "cannot delete a non-collaborative private wiki" do 
        delete :destroy, id: @private_wiki
        Wiki.all.should include(@private_wiki)
      end
    end

    context "as an admin user" do

      before (:each) do 
        @user.update_attribute(:level, "admin")
        @private_wiki2 = FactoryGirl.create(:wiki, private: true)
        @private_wiki2.users << @user
      end

      it "populates an array of wikis with all Wikis" do
        # to_a overrides paginate
        get :index
        assigns(:wikis).to_a.should eq(Wiki.all.to_a)
      end

      it "can view a public wiki" do
        get :show, :id => @wiki.id
        response.should be_success
      end

      it "can view a collaborative private wiki" do
        get :show, :id => @private_wiki2
        response.should be_success
      end

      it "can view a non-collaborative private wiki" do
        get :show, :id => @private_wiki.id
        response.should be_success
      end

      it "can navigate to the new wiki form" do
        get :new
        response.should be_success
      end

      it "can navigate to the edit wiki form for a public wiki" do
        get :edit, :id => @wiki.id
        response.should be_success
      end

      it "can navigate to the edit wiki form for a collaborative private wiki" do
        get :edit, :id => @private_wiki2.id
        response.should be_success
      end

      it "can navigate to the edit wiki form for a non-collaborative private wiki" do
        get :edit, :id => @private_wiki.id
        response.should be_success
      end

      it "can delete a public wiki" do
        delete :destroy, id: @wiki
        Wiki.all.should_not include(@wiki)
      end

      it "can delete a collaborative private wiki" do 
        delete :destroy, id: @private_wiki2
        Wiki.all.should_not include(@private_wiki2)
      end

      it "can delete a non-collaborative private wiki" do 
        delete :destroy, id: @private_wiki
        Wiki.all.should_not include(@private_wiki)
      end
    end

    context "as a guest user" do

      before (:each) do 
        sign_out @user
      end

      it "can see an index of wikis that are set to private: false" do
        # to_a overrides paginate
        get :index
        assigns(:wikis).to_a.should eq(Wiki.all.where(private: false).to_a)
      end

      it "can view a public wiki" do
        get :show, :id => @wiki.id
        response.should be_success
      end

      it "cannot view a private wiki" do
        get :show, :id => @private_wiki.id
        response.should_not be_success
      end

      it "flashes an error message upon failure to view" do
        get :show, :id => @private_wiki.id
        flash[:error].should eq("No show for you!")
      end

      it "cannot navigate to the new wiki form" do
        get :new
        response.should_not be_success
      end

      it "flashes an error message upon failure to visit wiki#new form" do
        get :new
        flash[:error].should eq("No new for you!")
      end

      it "cannot edit a public wiki" do
        get :edit, :id => @wiki.id
        response.should_not be_success
      end

      it "cannot edit a private wiki" do
        get :edit, :id => @private_wiki.id
        response.should_not be_success
      end

      it "flashes an error message upon failure to edit" do
        get :edit, :id => @private_wiki.id
        flash[:error].should eq("No edit for you!")
      end

      it "cannot delete a public wiki" do
        delete :destroy, id: @wiki
        Wiki.all.should include(@wiki)
      end

      it "cannot delete a public wiki" do
        delete :destroy, id: @private_wiki
        Wiki.all.should include(@private_wiki)
      end

      it "flashes an error message upon failure to destroy" do
        get :destroy, :id => @private_wiki.id
        flash[:error].should eq("No destroy for you!")
      end
    end
  end
end
