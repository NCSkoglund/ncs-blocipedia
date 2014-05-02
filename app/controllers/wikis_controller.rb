class WikisController < ApplicationController
  def index
    @wikis = Wiki.all
    @tags = Tag.all
  end

  def show
    @wiki = Wiki.find(params[:id])
    @tags = @wiki.tags
  end

  def new
  end

  def edit
  end
end
