class AddArchivedToDevices < ActiveRecord::Migration[8.0]
  def change
    add_column :devices, :archived, :boolean, default: false
    add_index :devices, :archived
  end
end
