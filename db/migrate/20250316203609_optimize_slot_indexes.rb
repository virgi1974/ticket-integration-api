class OptimizeSlotIndexes < ActiveRecord::Migration[8.0]
  def change
    remove_index :slots, name: "index_slots_on_starts_at"
    remove_index :slots, name: "index_slots_on_ends_at"

    add_index :slots, [ :starts_at, :ends_at ], name: "index_slots_on_starts_at_and_ends_at"
  end
end
