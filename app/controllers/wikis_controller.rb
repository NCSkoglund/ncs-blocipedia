class WikisController < ApplicationController

  def index
    @wikis_array = policy_scope(Wiki)
    authorize @wikis_array

    def pass_instance_var_to_search_block
      @wikis_array.map(&:id)
    end
    
    @wikis = Wiki.search do 
      fulltext params[:search]
      with(:id, pass_instance_var_to_search_block)  
      paginate :page => params[:page], :per_page => 5
    end.results
  
    @tags = policy_scope(Tag).sort_by { |t| t.tag.downcase }
  end

  def show
    @wiki = Wiki.find(params[:id])
    @tags = @wiki.tags.sort_by { |t| t.tag.downcase }
    authorize @wiki
  end

  def new
    @wiki = Wiki.new
    @wiki.collaborations.build
    @tag = Tag.new
    authorize @wiki

    # visibility scoping within the form select box for displaying a collection of Tags
    @tagz = policy_scope(Tag).sort_by { |t| t.tag.downcase }
  end

  def create 
    @wiki = Wiki.new(wiki_params)
    @wiki.owner = current_user
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
    @wiki.collaborations.build if @wiki.collaborations.count == 0
    @tags = @wiki.tags
    @tag = Tag.new
    authorize @wiki

    # visibility scoping within the form select box for visible Tags
    @tagz = policy_scope(Tag).sort_by { |t| t.tag.downcase }
  end

  def update
    @wiki = Wiki.find(params[:id])
    @tags = Tag.where(:id => params[:tags])

    authorize @wiki
    if @wiki.update_attributes(wiki_params)

      #newly written tags are created after the save but before the following destroy_all
      #if a new custom tag was created, manually add it to the @tags array
      if wiki_params[:tags_attributes]
        if wiki_params[:tags_attributes]["0"][:tag] != ""    # nesting for Rspec
          @tag = Tag.last  
          @tags << @tag
        end
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
    params.require(:wiki).permit(:title, :description, :body, :private, tags_attributes: [:id, :tag], collaborations_attributes: [:id, :user_id, :_destroy])
  end

end
