class Tag < ActiveRecord::Base
  has_and_belongs_to_many :wikis, join_table: :wikis_tags
  #belongs_to :wiki
end
