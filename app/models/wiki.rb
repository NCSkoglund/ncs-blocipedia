class Wiki < ActiveRecord::Base
  before_save :set_public
  has_and_belongs_to_many :tags,  join_table: :wikis_tags
  accepts_nested_attributes_for :tags, :reject_if => proc { |a| a['tag'].blank? }

  default_scope { order('created_at DESC') }
  scope :visible_to, ->(user) { (user.level?(:premium) || user.level?(:admin)) ? all : where(private: false) }

  validates :title, presence: true, format: { with: /\s*\S.{3,}\S\s*/, message: "title must contain at least five valid characters" }
  validates :body, length: { minimum: 20 }, presence: true
  
  private

  # prevent private field from being left as nil
  def set_public
    if self.private == nil 
      self.private = 0
    end
  end

end
