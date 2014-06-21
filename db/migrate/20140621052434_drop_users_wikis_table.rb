class DropUsersWikisTable < ActiveRecord::Migration
  def up
    drop_table :users_wikis
  end

  def down 
    raise ActiveRecord::IrreversibleMigration
  end
end
