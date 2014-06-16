class WikiPolicy < ApplicationPolicy

  def index?
     #individual record scoping occurs in wikis_controller.rb
     true
  end

  def show?
    if record.private == false
      true
    elsif user.present? && user.level?(:admin)
      true
    elsif user.present? && (user.level?(:premium) && (record.users.include?(user) || record.owner == user))
      true 
    else
      false
    end
  end

  def update?
    if user.present? && record.private == false
      true

    # turn this into a private function
    elsif user.present? && user.level?(:admin)
      true
    elsif user.present? && (user.level?(:premium) && (record.users.include?(user) || record.owner == user))
      true 
    else
      false
    end
  end

end