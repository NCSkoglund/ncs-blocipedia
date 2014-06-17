class WikiPolicy < ApplicationPolicy

  def index?
     #individual record scoping occurs in wikis_controller.rb
     true
  end

  def show?
    if record.private == false
      true
    else record.scope_helper(user)
    end
  end

  def update?
    if user.present? && record.private == false
      true
    else record.scope_helper(user)
    end
  end
  
end