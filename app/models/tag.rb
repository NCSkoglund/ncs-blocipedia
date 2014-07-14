class Tag < ActiveRecord::Base
  before_destroy :terminator
  before_save :cull 
  has_and_belongs_to_many :wikis, join_table: :wikis_tags

  validates :tag, uniqueness: true 
  
 # scope :begins_with, lambda { |letter| where("tag", start_with?(letter)) }

  private

  def terminator
    #if a tag has only one parent wiki, destroy the tag when its parent wiki is destroyed. 
    if self.wikis.count > 1  
      false
    end
  end
      
  def cull   
    # search for and cull orphaned tags from collection upon a tag.save event 
    # written so as to be triggered periodically without a cron event
    Tag.all.each do |t|
      if t.wikis.count == 0 
        t.destroy
      end
    end
  end

end
