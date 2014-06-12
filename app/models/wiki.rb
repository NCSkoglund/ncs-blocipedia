class Wiki < ActiveRecord::Base
  before_validation :set_public

  belongs_to :owner, class_name: "User"   #declare alias 'owner', keep separate from 'users'

  has_and_belongs_to_many :users, join_table: :users_wikis 
  
  has_and_belongs_to_many :tags,  join_table: :wikis_tags
  accepts_nested_attributes_for :tags, :reject_if => proc { |a| a['tag'].blank? }

  default_scope { order('title DESC') }#('created_at DESC') }
  
  validates :title, presence: true, format: { with: /\s*\S.{3,}\S\s*/, message: "title must contain at least five valid characters" }
  validates :body, length: { minimum: 20 }, presence: true
  validates :private, inclusion: { in: [true, false] }

  # privacy scoping for user levels; `self` here is the Wiki class
  def self.visible_wikis(user) 
    @visible_wikis = [] 
    if user.level?(:admin)
      @visible_wikis = self.all
    elsif user.level?(:premium)    
      self.all.each do |w|
        if ( w.users.include?(user) || w.owner == user ) 
          @visible_wikis << w
        end
      end
    else
      @visible_wikis = self.where(private: false)
    end
    @visible_wikis # this works incorrectly if not explicitly returned
  end
  
  def self.visible_tags(array) 
    @visible_tags = []
    array.each do |w|
      w.tags.each do |t|
        @visible_tags << t
      end
    end
    @visible_tags
  end

  private

  # TO DO: modify as default in migration? 
  # prevent private field from being left as nil
  def set_public
    if self.private == nil 
      self.private = 0
    end
  end

end
