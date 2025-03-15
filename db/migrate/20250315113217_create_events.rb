class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.uuid :uuid, null: false
      t.string :external_id, null: false
      t.string :title, null: false
      t.string :sell_mode, null: false
      t.string :organizer_company_id

      t.timestamps

      t.index :external_id, unique: true
      t.index :sell_mode
    end
  end
end
