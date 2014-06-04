class Tag < ActiveRecord::Base
  before_destroy :terminator
  after_destroy :cull
  has_and_belongs_to_many :wikis, join_table: :wikis_tags

  scope :visible_to, ->(user) { (user.level?(:premium) || user.level?(:admin)) ? all : joins(:wikis).where('wikis.private' => false) }

  validates :tag, uniqueness: true 
  
  private

  def terminator
    #if a tag has only one parent wiki, destroy the tag when its parent wiki is destroyed. 
    if self.wikis.count > 1  # changed from '!= 1'
      false
    end
  end
    
  def cull   
    # search for and cull random empty tags from collection upon a tag.destroy event (as opposed to wiki.destroy)
    # written so as to run periodically without a cron event
    # QUESTION:  This took too long when there are a lot of tags to cull
    # Move to after_save for more frequent usage?
    Tag.all.each do |t|
      if t.wikis.count == 0 
        t.destroy
      end
    end
  end

end
