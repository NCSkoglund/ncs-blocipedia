class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :set_level

  # declare alias 'owned_wikis'
  has_many :owned_wikis, foreign_key: "owner_id", class_name: "Wiki"
  
  has_many :collaborations
  has_many :wikis, :through => :collaborations
  
  validates :name, presence: true

  def level?(base_level)
    level == base_level.to_s
  end

  def visible_wikis
    visible_wikis = [] 
    if level?(:admin)
      visible_wikis = Wiki.all
    elsif level?(:premium) 
      public_array = Wiki.where(private: false) 
      owned_array = self.owned_wikis.to_a 
      collaborator_array = self.wikis.to_a
      
      visible_wikis = public_array.concat(owned_array).concat(collaborator_array)  
      visible_wikis = visible_wikis.uniq
    else
      visible_wikis = Wiki.where(private: false)
    end
    visible_wikis # this works incorrectly if not explicitly returned
  end

  private 

  def set_level
    self.level = "basic"
  end

end
