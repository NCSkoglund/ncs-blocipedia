class TagsController < ApplicationController

  def index
    current_user ? @wikis = current_user.visible_wikis : @wikis = Wiki.where(private: false) 
    
    # TO DO: still  needs collaborator tags added to query...
    @tags = Tag.joins(:wikis).
            where("wikis.private=false OR wikis.owner_id=?", current_user).uniq.
            sort_by { |t| t.tag.downcase }.group_by{|t| t.tag[0]}
    
    authorize @tags
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
    authorize @tag
  end

end
