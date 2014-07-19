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

  scope :privileged, -> { where(level: ['premium', 'admin']) }

  def level?(base_level)
    level == base_level.to_s
  end

  # for Wiki collaborator scoping
  def self.exclude_list(user_param, wiki_param)
    exclude_ids = wiki_param.users.map {|a| a.id } 
    exclude_ids << user_param.id
    user_list = User.privileged.reject { |a| exclude_ids.include?(a.id)}
    user_list    
  end

  private 

  def set_level
    self.level = "basic"
  end

end
