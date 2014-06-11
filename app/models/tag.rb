class Tag < ActiveRecord::Base
  before_destroy :terminator
  #after_save :cull  # this obliterates itself as an after-save callback
  has_and_belongs_to_many :wikis, join_table: :wikis_tags

  validates :tag, uniqueness: true 
  
  private

  def terminator
    #if a tag has only one parent wiki, destroy the tag when its parent wiki is destroyed. 
    if self.wikis.count > 1  
      false
    end
  end
    
  # TO DO: rewrite as a rake task  
  # def cull   
  #   # search for and cull random empty tags from collection upon a tag.save event 
  #   # written so as to run periodically without a cron event; rewrite as rake task
  #   Tag.all.each do |t|
  #     if t.wikis.count == 0 
  #       t.destroy
  #     end
  #   end
  # end

end
