class TagsController < ApplicationController

  def index
    current_user ? @wikis = Wiki.visible_wikis(current_user) : @wikis = Wiki.where(private: false) 
    @tags = Wiki.visible_tags(@wikis)
    authorize @tags
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
    authorize @tag
  end

end
