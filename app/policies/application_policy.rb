class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user 
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists? 
  end

  def create?
    user && user.present?
  end

  def new?
    create?
  end

  def update?
    user && user.present? && (record.private == false || user.level?(:premium) || user.level?(:admin))
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def scope
    # scope for guest users
    Pundit.policy_scope!(user, record.class)
  end

  def scope_helper(current_user, record)
    if record.private == false
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

