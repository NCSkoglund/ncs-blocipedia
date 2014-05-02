class ChangeWikisTags < ActiveRecord::Migration
  def change
    change_table :wikis_tags do |t|
      t.rename :part_id, :tag_id
    end
  end
end
