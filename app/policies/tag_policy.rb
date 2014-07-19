class TagPolicy < ApplicationPolicy

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
   end

    def resolve
      if user && user.level?("admin")
        scope.all
      elsif user
        # a premium user can see tags if they are assciated with a wiki that is public, or that they own or collaborate on
        scope.includes(wikis: :collaborations).where("wikis.private='f' OR wikis.owner_id=? OR collaborations.user_id=?",
          user, user).references(:wikis, :collaborations)
      else
        scope.includes(:wikis).where("wikis.private='f'").references(:wikis)
      end
    end
  end

  def index?
    true
  end

  def show? 
    if user && user.level?("admin") 
      true 
    # a premium user can see tags if they are assciated with a wiki that is public, or that they own or collaborate on      
    elsif Tag.includes(wikis: :collaborations).where("wikis.private='f' OR wikis.owner_id=? OR collaborations.user_id=?", 
            user, user).references(:wikis, :collaborations).
              include?(record) 
      true
    else
      false
    end
  end
end
