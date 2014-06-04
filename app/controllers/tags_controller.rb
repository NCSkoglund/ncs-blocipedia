class TagsController < ApplicationController

  def index
    current_user ? @tags = Tag.visible_to(current_user).uniq : @tags = Tag.joins(:wikis).where('wikis.private' => false).uniq
    authorize @tags
   end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
    authorize @tag
  end

end
