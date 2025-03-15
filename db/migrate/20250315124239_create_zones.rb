class CreateZones < ActiveRecord::Migration[8.0]
  def change
    create_table :zones do |t|
      t.uuid :uuid, null: false
      t.string :external_id, null: false
      t.references :slot, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :capacity, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :numbered, null: false

      t.timestamps
    end
  end
end
