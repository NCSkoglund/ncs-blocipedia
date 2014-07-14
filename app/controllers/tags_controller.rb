class TagsController < ApplicationController

  def index
    current_user ? @wikis = current_user.visible_wikis : @wikis = Wiki.where(private: false) 
    @tags = []
    @wikis.each { |w| w.grab_tags(@tags) }
    @tags = @tags.uniq.sort_by { |t| t.tag.downcase }
    authorize @tags

    @alpha = ('a'..'z').to_a
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
    authorize @tag
  end

end
