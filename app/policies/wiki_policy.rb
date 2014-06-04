class WikiPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    if user && user.present? && (user.level?(:premium) || user.level?(:admin))
        true
    else
      record.private == false
    end
    #QUESTION:  the `scope` in this line always throws an error :(
    #scope.where(:id => record.id).exists?  
  end

end