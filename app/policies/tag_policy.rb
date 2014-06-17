class TagPolicy < ApplicationPolicy

  def index?
    #individual record scoping occurs in tags_controller.rb
    true
  end

  def show? 
    user ? @wikis = user.visible_wikis : @wikis = Wiki.where(private: false) 
    @tags = []
    @wikis.each { |w| w.grab_tags(@tags) }
    @tags = @tags.uniq

    @tags.include?(record) ? true : false
  end

end
