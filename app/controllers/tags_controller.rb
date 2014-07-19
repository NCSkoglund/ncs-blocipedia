class TagsController < ApplicationController

  def index
    @tags = policy_scope(Tag).sort_by { |t| t.tag.downcase }.group_by{|t| t.tag[0]} 
    authorize @tags
  end

  def show
    @tag = Tag.find(params[:id])
    @wikis = @tag.wikis&policy_scope(Wiki)
    authorize @tag
  end

end
