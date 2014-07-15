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
  
  # add a wiki's tags to an existing list of tags
  def grab_tags(tag_array)
    newtags = self.tags.to_a
    tag_array.concat(newtags)
  end
  
  def is_wiki_viewable?(current_user)
    self.private == false || self.scope_helper(current_user)
  end

  def scope_helper(current_user)
    if current_user.present? && current_user.level?(:admin)
      true
    elsif current_user.present? && (current_user.level?(:premium) && (self.users.include?(current_user) || self.owner == current_user))
      true 
    else
      false
    end
  end
  
  private
  # prevent private field from being left as nil
  def set_public
    if self.private == nil 
      self.private = 0
    end
  end

end
