class TagsController < ApplicationController
 
  def index
    @wikis = Wiki.all
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
  end

end
