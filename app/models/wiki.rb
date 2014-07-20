class Wiki < ActiveRecord::Base
  before_validation :set_public

  belongs_to :owner, class_name: "User"   #declare alias 'owner', keep separate from 'users'

  has_many :collaborations
  has_many :users, :through => :collaborations
  accepts_nested_attributes_for :collaborations, allow_destroy: true
  
  has_and_belongs_to_many :tags,  join_table: :wikis_tags
  accepts_nested_attributes_for :tags, :reject_if => proc { |a| a['tag'].blank? }

  default_scope { order('title DESC') }

  validates :title, presence: true, format: { with: /\s*\S.{3,}\S\s*/, message: "title must contain at least five valid characters" }
  validates :body, length: { minimum: 20 }, presence: true
  validates :private, inclusion: { in: [true, false] }

  searchable do 
    integer :id
    text :title, :description, :body
    text :tags do 
      tags.map(&:tag)
    end
    boolean :private
  end
  
  private
  # prevent private field from being left as nil
  def set_public
    if self.private == nil 
      self.private = 0
    end
  end

end
