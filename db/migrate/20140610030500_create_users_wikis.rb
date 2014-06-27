class CreateUsersWikis < ActiveRecord::Migration
  def change
    create_table :users_wikis, id: false do |t|
      t.belongs_to :wiki
      t.belongs_to :user
    end
  end
end
