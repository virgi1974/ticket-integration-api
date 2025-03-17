class AddcurrentToSlots < ActiveRecord::Migration[8.0]
  def change
    add_column :slots, :current, :boolean, default: true, null: false
    add_index :slots, :current
  end
end
