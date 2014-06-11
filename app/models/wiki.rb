class Wiki < ActiveRecord::Base
  before_validation :set_public

  #declare alias 'owner', keep separate from 'users'
  belongs_to :owner, class_name: "User"   

  has_and_belongs_to_many :users, join_table: :users_wikis 
  
  has_and_belongs_to_many :tags,  join_table: :wikis_tags
  accepts_nested_attributes_for :tags, :reject_if => proc { |a| a['tag'].blank? }

  default_scope { order('title DESC') }#('created_at DESC') }
  
  validates :title, presence: true, format: { with: /\s*\S.{3,}\S\s*/, message: "title must contain at least five valid characters" }
  validates :body, length: { minimum: 20 }, presence: true
  validates :private, inclusion: { in: [true, false] }

  private

  # TO DO: modify as default in migration? 
  # prevent private field from being left as nil
  def set_public
    if self.private == nil 
      self.private = 0
    end
  end

end
