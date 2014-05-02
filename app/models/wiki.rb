class Wiki < ActiveRecord::Base
  
  has_and_belongs_to_many :tags,  join_table: :wikis_tags
  #has_many :tags

  validates :title, presence: true, format: { with: /\s*\S.{3,}\S\s*/, message: "title must contain at least five valid characters" }
  validates :body, length: { minimum: 20 }, presence: true
  
end
