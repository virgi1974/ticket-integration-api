class CreateSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :slots do |t|
      t.uuid :uuid, null: false
      t.string :external_id, null: false
      t.references :event, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.datetime :sell_from, null: false
      t.datetime :sell_to, null: false
      t.boolean :sold_out, default: false

      t.timestamps

      t.index :starts_at
      t.index :ends_at
    end
  end
end
