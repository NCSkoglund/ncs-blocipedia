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
    if user && user.present?
      scope_helper(user, record)
    elsif record.private == false
      true
    else 
      false
    end
  end

  def update?
    if user && user.present?
      scope_helper(user, record)
    else 
      false
    end
  end
end
