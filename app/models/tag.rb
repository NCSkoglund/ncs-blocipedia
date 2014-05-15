class Tag < ActiveRecord::Base
  has_and_belongs_to_many :wikis, join_table: :wikis_tags

  validates :tag, uniqueness: true

  #if a tag has no wikis belonging to it, destroy the tag.  
  #should this be private?
  def terminator
  #  puts "********* self.tag= #{self.tag}"
  #  puts "********* self.wikis.count= #{self.wikis.count}"
    if self.wikis.count == 1
      self.destroy
    end
  end

end
