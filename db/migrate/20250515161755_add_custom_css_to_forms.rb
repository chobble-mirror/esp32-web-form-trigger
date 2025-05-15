class AddCustomCssToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :custom_css, :text
  end
end
