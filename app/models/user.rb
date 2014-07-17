class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :set_level

  # declare alias 'owned_wikis'
  has_many :owned_wikis, foreign_key: "owner_id", class_name: "Wiki"
  
  has_many :collaborations
  has_many :wikis, :through => :collaborations, :uniq => true
  
  validates :name, presence: true

  scope :privileged, -> { where(level: ['premium', 'admin']) }
  
  # for Wiki collaborator scoping
  def self.exclude_list(user_param, wiki_param)
    exclude_ids = wiki_param.users.map {|a| a.id }
    exclude_ids << user_param.id
    @user_list = User.privileged.reject { |a| exclude_ids.include?(a.id)}
    @user_list    
  end

  def level?(base_level)
    level == base_level.to_s
  end

  def visible_wikis
    if level?(:admin)
      Wiki.all
    elsif level?(:premium) 
      Wiki.includes(:collaborations).where("private=false OR owner_id=? OR collaborations.user_id=?",
         self.id, self.id).references(:collaborations)
    else
      Wiki.where(private: false)
    end
  end

  private 

  def set_level
    self.level = "basic"
  end

end
