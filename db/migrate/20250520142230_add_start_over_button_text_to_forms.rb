class AddStartOverButtonTextToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :start_over_button_text, :string
  end
end
