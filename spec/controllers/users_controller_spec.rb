require 'spec_helper'

describe UsersController do

  before (:each) do
    #create a basic user
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'show'" do
    
    it "should be successful" do
      get :show, :id => @user.id
      response.should be_success
    end
    
    it "finds the right user" do
      get :show, :id => @user.id
      assigns(:user).should == @user
    end
    
  end

  describe "user level permissions regarding users_controller" do

    context "as a basic user" do

      it "can navigate to view its own user profile" do
        get :show, :id => @user.id
        response.should be_success
      end

      it "cannot navigate to view a list of users" do
        get :index
        response.should be_success
      end
    end

    context "as a premium user" do
      before(:each) do
        @user.update_attribute(:level, "premium")
      end

      it "can navigate to view its own user profile" do
        get :show, :id => @user.id
        response.should be_success
      end

      it "cannot navigate to view a list of users" do
        get :index
        response.should be_success
      end
    end

    context "as an admin user" do
      before(:each) do
        @user.update_attribute(:level, "admin")
      end
      
      it "can navigate to view its own user profile" do
        get :show, :id => @user.id
        response.should be_success
      end

      it "cannot navigate to view a list of users" do
        get :index
        response.should be_success
      end
    end

    context "as a guest user" do

      before (:each) do 
        sign_out @user
      end

      it "cannot navigate to view a list of users" do
        get :index
        response.should_not be_success
      end

      it "should redirect to the sign in page upon denial of user index" do
        get :index
        response.should redirect_to new_user_session_path
      end

      it "should display a flash message upon denial of user index" do
        get :index
        flash[:alert].should eq("You need to sign in or sign up before continuing.")
      end

      it "cannot navigate to view a user's profile" do
        get :show, :id => @user.id
        response.should_not be_success
      end

      it "should redirect to the sign in page upon denial of user profile" do
        get :show, :id => @user.id
        response.should redirect_to new_user_session_path
      end

      it "should display a flash message upon denial of user profile" do
        get :show, :id => @user.id
        flash[:alert].should eq("You need to sign in or sign up before continuing.")
      end
    end
  end 
end
