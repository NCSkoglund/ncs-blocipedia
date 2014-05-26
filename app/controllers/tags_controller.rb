class TagsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found 

  def index
    @wikis = Wiki.all
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
  end

end
