require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "user permissions regarding home controller" do

    before(:each) do
      #create a basic user
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "renders the home page for a basic user" do
      get 'index'
      response.should be_success
    end

    it "renders the home page for a premium user" do
      @user.update_attribute(:level, 'premium')
      get 'index'
      response.should be_success
    end

    it "renders the home page for an admin user" do
      @user.update_attribute(:level, 'admin')
      get 'index'
      response.should be_success
    end

    it "renders the home page for a guest user" do
      sign_out @user
      get 'index'
      response.should be_success
    end
  end

end
