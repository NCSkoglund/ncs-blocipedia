class TagsController < ApplicationController

  def index
 
    # isolate the wikis that are available to the current user
    if current_user && current_user.level?(:admin)
      @wikis = Wiki.all
    elsif current_user && current_user.level?(:premium) 
      @the_wikis_of_current_user = []
      Wiki.all.each do |w|
        if w.users.include?(current_user) || w.owner == current_user 
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

    authorize @tags
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
    authorize @tag
  end

end
