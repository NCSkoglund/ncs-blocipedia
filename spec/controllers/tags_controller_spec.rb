require 'spec_helper'

describe TagsController do

  before (:each) do
    @tag = FactoryGirl.create(:tag)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show', :id => @tag.id
      response.should be_success
    end
  end

end
