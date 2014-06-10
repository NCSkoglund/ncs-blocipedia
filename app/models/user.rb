class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # declare alias 'owned_wikis'
  has_many :owned_wikis, foreign_key: "owner_id", class_name: "Wiki"
  
  has_and_belongs_to_many :wikis, join_table: :users_wikis 
  
  validates :name, presence: true
  validates :level, presence: true

  def level?(base_level)
    level == base_level.to_s
  end

end
