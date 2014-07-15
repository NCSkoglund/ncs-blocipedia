class TagPolicy < ApplicationPolicy

  def index?
    #individual record scoping occurs in tags_controller.rb
    true
  end

  def show? 
    
    # TO DO: still  needs collaborator tags added to query...
    @tags = Tag.joins(:wikis).where("wikis.private=false OR wikis.owner_id=?", user)
    @tags.include?(record) ? true : false
  end

end
