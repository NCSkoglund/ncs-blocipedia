class WikisController < ApplicationController

  def index
     # scope for guest users
    current_user ? @wikis = Wiki.visible_to(current_user) : @wikis = Wiki.where(private: false )

    @tags = Tag.all
    # for privacy scoping regarding tags and public/private wikis
    # QUESTION: can this logic be moved into model to keep controller skinny?
    @public_tags = []
    @wikis.each do |w|
      w.tags.each do |t|
        @public_tags << t
      end
    end
    authorize @wikis
  end

  def show
    @wiki = Wiki.find(params[:id])
    @tags = @wiki.tags
    authorize @wiki
  end

  def new
    @wiki = Wiki.new
    @tag = Tag.new
    authorize @wiki
  end

  def create 
    @wiki = Wiki.new(wiki_params)

    @tags = Tag.where(:id => params[:tags])  # Allow preexisting tags to be associated with the wiki from select box
    @wiki.tags << @tags # associate the selected tags to the wiki and create records in the join table.
    
    authorize @wiki
    if @wiki.save
      redirect_to @wiki, notice: "Wiki was saved successfully."
    else
      flash[:error] = "An error occurred in the create method, please try again."
      @tag = Tag.new
      render :new
    end
  end

  def edit
    @wiki = Wiki.find(params[:id])
    @tags = @wiki.tags
    @tag = Tag.new
    authorize @wiki
  end

  def update
    @wiki = Wiki.find(params[:id])
    @tags = Tag.where(:id => params[:tags])
    @tag_count = Tag.all.count 

    authorize @wiki
    if @wiki.update_attributes(wiki_params)
      #newly written tags are created after the save but before the following destroy_all
      #if a new custom tag was created, manually add it to the @tags array
      @new_tag_count = Tag.all.count
      if @new_tag_count > @tag_count
        @tag = Tag.last  
        @tags << @tag
      end

      @wiki.tags.destroy_all #only disassociate previous tags if the wiki form contains no errors
      @wiki.tags << @tags  # associate the selected tags to the wiki and create records in the join table.
      flash[:notice] = "Wiki was updated."
      redirect_to @wiki
    else
      flash[:error] = "There was an error updating the wiki.  Please try again."
      @tag = Tag.new #reset the custom tag field if an error occurs
      render :edit
    end
  end

  def destroy
    @wiki = Wiki.find(params[:id])
    title = @wiki.title

    # a tag should be automatically destroyed when it has no more wikis to belong to
    @wiki.tags.each do |t|   # this counts self.wiki.count as pre-destroy count.
      t.destroy
    end 

    authorize @wiki
    if @wiki.destroy
      redirect_to wikis_path, notice: "\"#{title}\" was deleted successfully."
    else 
      flash[:error] = "Error deleting wiki.  Please try again."
      render :show
    end
  end

  private

  def wiki_params
    params.require(:wiki).permit(:title, :description, :body, :private, tags_attributes: [:id, :tag])
  end

end
