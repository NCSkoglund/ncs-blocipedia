class Collaboration < ActiveRecord::Base
  belongs_to :user
  belongs_to :wiki
  #validates :user_id, presence: false, uniqueness: { scope: :wiki_id, message: "This is a message" }
  
  after_save :check_redundant
  
  private

  # don't create duplicate collaborators 
  def check_redundant
    this_wiki = Wiki.find(self.wiki_id)
    existing_collaborator_ids = this_wiki.users.map { |a| a.id } 
    
    if existing_collaborator_ids != existing_collaborator_ids.uniq
      self.destroy
    else
      true
    end
  end
end
