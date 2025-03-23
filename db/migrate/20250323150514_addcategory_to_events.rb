class AddcategoryToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :category, :string
  end
end
