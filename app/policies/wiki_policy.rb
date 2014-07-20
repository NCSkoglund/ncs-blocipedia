class WikiPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user && user.level?("admin")  
        scope.all 
      elsif user && user.level?("premium")
        # a premium user can see wikis if they are public, they are the owner or they are a collaborator
        scope.includes(:collaborations).where("private=false OR owner_id=? OR collaborations.user_id=?",
          user, user).references(:collaborations)
      else
        scope.where("private='f'")
      end
    end
  end

  def index?
     true
  end

  def show?
    if record.private == false
      true
    elsif user && user.level?(:admin)
      true
    elsif user && user.level?(:premium) && (record.users.include?(user) || record.owner == user)
      true
    else
      false
    end
  end

  def update?
    if user.nil?
      false
    elsif record.private == false 
      true
    elsif user.level?(:admin)
      true
    elsif user.level?(:premium) && (record.users.include?(user) || record.owner == user)
      true
    else
      false
    end
  end
end
