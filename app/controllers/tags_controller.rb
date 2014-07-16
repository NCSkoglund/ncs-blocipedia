class TagsController < ApplicationController

  def index
    current_user ? @wikis = current_user.visible_wikis : @wikis = Wiki.where(private: false)   
    if current_user && current_user.level?("admin")
      @tags = Tag.all
    else 
      @tags = Tag.includes(wikis: :collaborations).
            where("wikis.private='f' OR wikis.owner_id=? OR collaborations.user_id=?", current_user, current_user).
            references(:wikis, :collaborations).uniq.
            sort_by { |t| t.tag.downcase }.group_by{|t| t.tag[0]}   
    end
    authorize @tags
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
    authorize @tag
  end

end
