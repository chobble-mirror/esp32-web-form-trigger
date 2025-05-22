class AddRequireLoginToForms < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :require_login, :boolean, default: false
  end
end
