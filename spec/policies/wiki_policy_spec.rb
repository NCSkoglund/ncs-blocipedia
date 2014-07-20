require 'spec_helper'

describe WikiPolicy do
  subject { WikiPolicy }

  before (:each) do
    @user = FactoryGirl.create(:user)
    @wiki = FactoryGirl.create(:wiki)
  end

  permissions :index? do 
    
    it "allows an admin user to see wikis#index" do 
      @user.update_attribute(:level, "admin")
      expect(subject).to permit(@user)
    end

    it "allows a premium user to see wikis#index" do
      @user.update_attribute(:level, "premium")  
      expect(subject).to permit(@user)
    end

    it "allows a basic user to see wikis#index" do 
      expect(subject).to permit(@user)
    end

    it "allows a guest to see wikis#index" do 
      expect(subject).to permit(nil)
    end
  end

  permissions :show? do 

    context "show a public wiki" do

      it "allows admin users to see a public wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end

      it "allows premium users to see a public wiki" do
        @user.update_attribute(:level, "premium") 
        expect(subject).to permit(@user, @wiki)
      end

      it "allows basic users to see a public wiki" do 
        expect(subject).to permit(@user, @wiki)
      end

      it "allows guests to see public wikis" do 
        expect(subject).to permit(nil, @wiki)
      end
    end

    context "show a private wiki" do
      before (:each) do 
        @wiki.update_attribute(:private, true)
      end

      it "allows admin users to see any private wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow premium users to see a private wiki if they are neither collaborator nor owner" do 
        @user.update_attribute(:level, "premium")
        expect(subject).to_not permit(@user, @wiki)
      end

      it "allows premium users to see a private wiki if they are the wiki owner" do 
        @user.update_attribute(:level, "premium")
        @wiki.owner = @user
        expect(subject).to permit(@user, @wiki)
      end

      it "allows premium users to see a private wiki if they are a collaborator" do
        @user.update_attribute(:level, "premium")
        @wiki.users << @user
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow basic users to see private wikis" do 
        expect(subject).to_not permit(@user, @wiki)
      end

      it "does not allow guests to see private wikis" do 
        expect(subject).to_not permit(nil, @wiki)
      end
    end
  end

  permissions :new? do 

    it "allows admin users to see the new wiki form" do 
      @user.update_attribute(:level, "admin")
      expect(subject).to permit(@user)
    end
    
    it "allows premium users to see the new wiki form" do 
      @user.update_attribute(:level, "premium")
      expect(subject).to permit(@user)
    end

    it "allows basic users to see the new wiki form" do 
      expect(subject).to permit(@user)
    end

    it "does not allow guests to see the new wiki form" do 
      expect(subject).to_not permit(nil)
    end
  end

  permissions :create? do

    it "allows admin users to create a wiki" do 
      @user.update_attribute(:level, "admin")
      expect(subject).to permit(@user, @wiki)
    end

    it "allows premium users to create a wiki" do
      @user.update_attribute(:level, "premium") 
      expect(subject).to permit(@user, @wiki)
    end

    it "allows basic users to create a wiki" do 
      expect(subject).to permit(@user, @wiki)
    end

    it "does not allow guests to create wikis" do 
      expect(subject).to_not permit(nil, @wiki)
    end
  end

  permissions :edit? do 

    context "edit a public wiki" do

      it "allows admin users to see the edit wiki form for a public wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end
    
      it "allows premium users to see the edit wiki form for a public wiki" do 
        @user.update_attribute(:level, "premium")
        expect(subject).to permit(@user, @wiki)
      end

      it "allows basic users to see the edit wiki form for a public wiki" do 
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow guests to see the edit wiki form for a public wiki" do 
        expect(subject).to_not permit(nil, @wiki)
      end
    end

    context "edit a private wiki" do

      before (:each) do 
        @wiki.update_attribute(:private, true)
      end

      it "allows admin users to see the edit wiki form for any private wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end
    
      it "does not allow premium users to see the edit wiki form for a private wiki if they are neither collaborator nor owner" do 
        @user.update_attribute(:level, "premium")
        expect(subject).to_not permit(@user, @wiki)
      end

      it "allows premium users to see the edit wiki form for a private wiki if they are the owner" do 
        @user.update_attribute(:level, "premium")
        @wiki.owner = @user
        expect(subject).to permit(@user, @wiki)
      end

      it "allows premium users to see the edit wiki form for a private wiki if they are a collaborator" do 
        @user.update_attribute(:level, "premium")
        @wiki.users << @user
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow basic users to see the edit wiki form for a private wiki" do 
        expect(subject).to_not permit(@user, @wiki)
      end

      it "does not allow guests to see the edit wiki form for a private wiki" do 
        expect(subject).to_not permit(nil, @wiki)
      end
    end
  end

  permissions :update? do 

    context "update a public wiki" do

      it "allows admin users to update a public wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end
    
      it "allows premium users to update a public wiki" do 
        @user.update_attribute(:level, "premium")
        expect(subject).to permit(@user, @wiki)
      end

      it "allows basic users to update a public wiki" do 
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow guests to update a public wiki" do 
        expect(subject).to_not permit(nil, @wiki)
      end
    end

    context "update a private wiki" do

      before (:each) do 
        @wiki.update_attribute(:private, true)
      end

      it "allows admin users to update any private wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end
    
      it "does not allow premium users to update a private wiki if they are neither collaborator nor owner" do 
        @user.update_attribute(:level, "premium")
        expect(subject).to_not permit(@user, @wiki)
      end

      it "allows premium users to update a private wiki if they are the owner" do 
        @user.update_attribute(:level, "premium")
        @wiki.owner = @user
        expect(subject).to permit(@user, @wiki)
      end

      it "allows premium users to update a private wiki if they are a collaborator" do 
        @user.update_attribute(:level, "premium")
        @wiki.users << @user
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow basic users to update a private wiki" do 
        expect(subject).to_not permit(@user, @wiki)
      end

      it "does not allow guests to update a private wiki" do 
        expect(subject).to_not permit(nil, @wiki)
      end
    end
  end

  permissions :destroy? do 

    context "destroy a public wiki" do

      it "allows admin users to destroy a public wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end
    
      it "allows premium users to destroy a public wiki" do 
        @user.update_attribute(:level, "premium")
        expect(subject).to permit(@user, @wiki)
      end

      it "allows basic users to destroy a public wiki" do 
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow guests to destroy a public wiki" do 
        expect(subject).to_not permit(nil, @wiki)
      end
    end

    context "destroy a private wiki" do

      before (:each) do 
        @wiki.update_attribute(:private, true)
      end

      it "allows admin users to destroy any private wiki" do 
        @user.update_attribute(:level, "admin")
        expect(subject).to permit(@user, @wiki)
      end
    
      it "does not allow premium users to destroy a private wiki if they are neither collaborator nor owner" do 
        @user.update_attribute(:level, "premium")
        expect(subject).to_not permit(@user, @wiki)
      end

      it "allows premium users to destroy a private wiki if they are the owner" do 
        @user.update_attribute(:level, "premium")
        @wiki.owner = @user
        expect(subject).to permit(@user, @wiki)
      end

      it "allows premium users to destroy a private wiki if they are a collaborator" do 
        @user.update_attribute(:level, "premium")
        @wiki.users << @user
        expect(subject).to permit(@user, @wiki)
      end

      it "does not allow basic users to destroy a private wiki" do 
        expect(subject).to_not permit(@user, @wiki)
      end

      it "does not allow guests to destroy a private wiki" do 
        expect(subject).to_not permit(nil, @wiki)
      end
    end
  end
end
