class CreateWikiTagsTable < ActiveRecord::Migration
  def change
    create_table :wikis_tags, id: false do |t|
      t.belongs_to :wiki
      t.belongs_to :part
    end
  end
end
