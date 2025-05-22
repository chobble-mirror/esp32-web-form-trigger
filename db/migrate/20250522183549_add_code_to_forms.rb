class AddCodeToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :code, :string, limit: 12
    add_index :forms, :code, unique: true
  end
end
