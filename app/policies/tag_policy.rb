class TagPolicy < ApplicationPolicy

  def index?
    #individual record scoping occurs in tags_controller.rb
    true
  end

  def show? 
    @tags = Tag.includes(wikis: :collaborations).where("wikis.private='f' OR wikis.owner_id=? OR collaborations.user_id=?", user, user).references(:wikis, :collaborations)
    if user && user.level?("admin") 
      true 
    elsif @tags.include?(record) 
      true
    else
      false
    end
  end

end
