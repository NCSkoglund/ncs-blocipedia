class Tag < ActiveRecord::Base
  before_destroy :terminator
  has_and_belongs_to_many :wikis, join_table: :wikis_tags

  validates :tag, uniqueness: true 
  
  private

  #if a tag has no wikis belonging to it, destroy the tag. 
  def terminator
    if self.wikis.count != 1
      false
    end
  end

end
