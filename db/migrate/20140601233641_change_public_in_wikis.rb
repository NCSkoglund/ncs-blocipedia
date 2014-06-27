class ChangePublicInWikis < ActiveRecord::Migration
  def change
    change_table :wikis do |t|
      t.rename :public, :private
    end
  end
end
