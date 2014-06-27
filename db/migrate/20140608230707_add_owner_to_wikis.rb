class AddOwnerToWikis < ActiveRecord::Migration
  def change
    add_column :wikis, :owner_id, :integer
  end
end
