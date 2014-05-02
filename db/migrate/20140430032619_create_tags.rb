class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :tag
      t.references :wiki, index: true

      t.timestamps
    end
    add_index :tags, :tag
  end
end
