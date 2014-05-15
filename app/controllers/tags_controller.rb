class TagsController < ApplicationController
  def index
    @wikis = Wiki.all
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis
  end

  # def create
  #   #@wiki = Wiki.new
  #  # @tags = @wiki.tags

  #   @tag = Tag.new(tag_params)
  # #  @wiki.tags << @tag

  # #  @wiki = Tag.where(:id => params[:tags])
  #   #@tag.wiki = Wiki.find(params[:wiki_id])  # This is necessary to associate the newly created tag with its parent wiki.
  #  # @tag.save

  #   if @tag.save
  #     flash[:notice] = "Tag was saved successfully."
  #   else
  #     flash[:error] = "There was an error saving the tag.  Please try again."
  #   end

  # end

  # def destroy
  # end

  # private 

  # def tag_params
  #   params.require(:tag).permit(:tag)
  # end
  
end
