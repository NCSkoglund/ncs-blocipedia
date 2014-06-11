class TagPolicy < ApplicationPolicy

  def index?
    #individual record scoping occurs in tags_controller.rb
    true
  end

  def show?
  
  # this is a duplicate of code from tags_controller#index
  # isolate the wikis that are available to the current user
    if user.present? && user.level?(:admin)
      @wikis = Wiki.all
    elsif user.present? && user.level?(:premium) 
      @the_wikis_of_current_user = []
      Wiki.all.each do |w|
        if w.users.include?(user) || w.owner == user 
          @the_wikis_of_current_user << w 
        end
      end
      @wikis = @the_wikis_of_current_user
    else 
      # Guest users & basic users
      @wikis = Wiki.where(private: false)
    end

    # isolate tags that belong to the wikis that are available to the current user
    @tags = []
    @wikis.each do |w|  # this runs on @wikis after user-privacy scoping has already been performed
      w.tags.each do |t|
        @tags << t
      end
    end

    @tags.include?(record) ? true : false
  end

end
