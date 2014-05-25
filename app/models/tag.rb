class Tag < ActiveRecord::Base
  before_destroy :terminator
  has_and_belongs_to_many :wikis, join_table: :wikis_tags

  validates :tag, uniqueness: true 
  
  private

  #if a tag has only one parent wiki, destroy the tag when its parent wiki is destroyed. 
  def terminator
    if self.wikis.count > 1  # changed from '!= 1'
      false
    end
  end

end
