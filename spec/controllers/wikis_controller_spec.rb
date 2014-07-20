require 'spec_helper'

describe WikisController do

  before (:each) do
    @wiki = FactoryGirl.create(:wiki)
    @private_wiki = FactoryGirl.create(:wiki, private: true)
    # create a basic user
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'index'" do

    # Caveats:
    # calling `.to_a` overrides will_paginate breakage
    # run tests on `:wikis_array` instead of `:wikis` to avoid Sunspot breakage
    
    before (:each) do
      get :index
    end

    it "returns http success" do
      expect(response).to be_success
    end

    it "renders the :index view" do
      expect(response).to render_template :index
    end    
  end

  describe "GET 'index' scoping as a basic user" do

    before (:each) do
      get :index
    end

    it "populates an array of publicly visible wikis" do   
      expect(assigns(:wikis_array).to_a).to eq(Wiki.where(private: false))
    end

    it "does not include private wikis" do
      expect(assigns(:wikis_array)).to_not include(@private_wiki)
    end

    describe "tag privacy given a basic user" do

      before (:each) do
        @tag = FactoryGirl.create(:tag)
        @wiki.tags << @tag

        @private_tag = FactoryGirl.create(:tag)

        # @private_tag belongs exclusively to a private wiki
        @private_wiki.tags << @private_tag
        
        # @tag is shared between a public and a private wiki
        @private_wiki.tags << @tag
        
        get :index
      end

      it "populates an array of tags that belong to public wikis" do
        expect(assigns(:tags)).to eq(Tag.includes(:wikis).where("wikis.private='f'").references(:wikis))
      end

      it "populates an array of tags including those tags belonging to both public and private wikis" do  
        expect(assigns(:tags)).to include(@tag)
      end

      it "populates an array of tags excluding those tags belonging exclusively to private wikis" do
        expect(assigns(:tags)).to_not include(@private_tag)
      end
    end
  end

  describe "GET 'index' scoping as a premium user" do

    before (:each) do
      @user.update_attribute(:level, "premium") 
      get :index
    end

    it "populates an array of public wikis and private wikis where the user is a collaborator or owner" do   
      expect(assigns(:wikis_array).to_a).to eq(Wiki.includes(:collaborations).
        where("private=false OR owner_id=? OR collaborations.user_id=?", @user, @user).references(:collaborations))
    end

    it "does not include non-collaborative private wikis" do
      expect(assigns(:wikis_array)).to_not include(@private_wiki)
    end

    it "includes collaborative private wikis" do   
      @private_wiki.users << @user
      get :index
      expect(assigns(:wikis_array)).to include(@private_wiki) 
    end
  end

  describe "GET 'index' scoping as an admin user" do

    before (:each) do
       @user.update_attribute(:level, "admin")
       get :index
    end

    it "populates an array of all Wikis" do  
      expect(assigns(:wikis_array).to_a).to eq(Wiki.all)
    end

    it "includes non-collaborative private wikis" do   
      expect(assigns(:wikis_array)).to include(@private_wiki) 
    end
  end

  describe "GET 'index' scoping as a guest user" do

    before (:each) do 
      sign_out @user
      get :index
    end

    it "populates an array of publicly visible wikis" do   
      expect(assigns(:wikis_array).to_a).to eq(Wiki.where(private: false))
    end

    it "does not include private wikis" do
      expect(assigns(:wikis_array)).to_not include(@private_wiki)
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

      it "flashes a Pundit error message upon failure to render :show template if user is not authorized" do
        @private_wiki = FactoryGirl.create(:wiki, private: true)
        get :show, :id => @private_wiki.id
        flash[:error].should eq("No show for you!")
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

    it "flashes a Pundit error message upon failure to render :new template if user is not authorized" do
      sign_out @user
      get 'new'
      flash[:error].should eq("No new for you!")
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
        expect(Wiki.all).to include(assigns(:wiki))
      end

      it "redirects to the new wiki" do
        expect(response).to redirect_to assigns(:wiki)
      end
      
      it "assigns the given tag to the wiki" do
        expect(assigns(:wiki).tags.first).to eq(@tag)
      end
      
      it "only sets the given number of tags in the wiki" do
        expect(Wiki.first.tags.length).to eq(1)
      end

      it "flashes a Pundit error message upon failure to create if user is not authorized" do
        sign_out @user
        post :create, wiki: @attr, tags: @tag
        expect(flash[:error]).to eq("No create for you!")
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

      it "flashes a Pundit error message upon failure to create if user is not authorized" do
        sign_out @user
        post :create, wiki: @attr
        flash[:error].should eq("No create for you!")
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

    it "flashes a Pundit error message upon failure to render :edit template if user is not authorized" do
      @private_wiki = FactoryGirl.create(:wiki, private: true)
      get :edit, :id => @private_wiki.id
      flash[:error].should eq("No edit for you!")
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

      it "flashes a Pundit error message upon failure to update if user is not authorized" do
        @private_wiki = FactoryGirl.create(:wiki, private: true)
        put :update, id: @private_wiki, wiki: @new_attr, tags: @previous_tag
        flash[:error].should eq("No update for you!")
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

      it "flashes a Pundit error message upon failure to update if user is not authorized" do
        @private_wiki = FactoryGirl.create(:wiki, private: true)
        put :update, id: @private_wiki, wiki: @new_attr
        flash[:error].should eq("No update for you!")
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

      it "flashes a Pundit error message upon failure to destroy if user is not authorized" do
        @private_wiki = FactoryGirl.create(:wiki, private: true)
        get :destroy, id: @private_wiki
        flash[:error].should eq("No destroy for you!")
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
end
