class Tag < ActiveRecord::Base
  has_and_belongs_to_many :wikis, join_table: :wikis_tags
  before_destroy :terminator

  validates :tag, uniqueness: true

  #if a tag has no wikis belonging to it, destroy the tag.  
  
  private

  def terminator
    if self.wikis.count != 1
      false
    end
  end

end
