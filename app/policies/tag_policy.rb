class TagPolicy < ApplicationPolicy

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
   end

    def resolve
      if user.nil? 
        scope.includes(:wikis).where("wikis.private='f'").references(:wikis)
      elsif user.level?("admin")
        scope.all
      elsif user.level?("premium") # a premium user can see tags if they are assciated with a wiki that is public, or that they own or collaborate on
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
    if user.nil? 
      true if record.wikis.where(private: false).count > 0
    elsif user.level?("admin") 
      true 
    elsif user.level?("premium") # a premium user can see tags if they are assciated with a wiki that is public, or that they own or collaborate on      
      true if record.wikis.includes(:collaborations).
                where("private='f' OR owner_id=? or collaborations.user_id=?", user, user).
                  references(:collaborations).count > 0
    else
      true if record.wikis.where("private='f' OR owner_id=?", user).count >0
    end
  end
end
