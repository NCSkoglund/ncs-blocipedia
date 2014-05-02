class ChangeTags < ActiveRecord::Migration
  def change
    change_table :tags do |t|
      t.remove :wiki_id
    end
  end
end
