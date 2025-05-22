class AddTokenValiditySecondsToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :token_validity_seconds, :integer, default: 60, null: false
  end
end
