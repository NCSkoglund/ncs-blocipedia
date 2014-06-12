class TagPolicy < ApplicationPolicy

  def index?
    #individual record scoping occurs in tags_controller.rb
    true
  end

  def show? 
    user ? @wikis = Wiki.visible_wikis(user) : @wikis = Wiki.where(private: false) 
    @tags = Wiki.visible_tags(@wikis)

    @tags.include?(record) ? true : false
  end

end
