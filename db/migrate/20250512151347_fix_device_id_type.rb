class FixDeviceIdType < ActiveRecord::Migration[8.0]
  def up
    # First, we need to drop the foreign key
    remove_foreign_key :submissions, :devices
    
    # Then drop the index that uses this column
    remove_index :submissions, name: "index_submissions_on_device_and_credit"
    remove_index :submissions, name: "index_submissions_on_device_id"
    
    # Change the column type to string(12)
    change_column :submissions, :device_id, :string, limit: 12
    
    # Recreate the indexes
    add_index :submissions, :device_id
    add_index :submissions, [:device_id, :credit_claimed], name: "index_submissions_on_device_and_credit"
    
    # Add the foreign key back
    add_foreign_key :submissions, :devices
  end
  
  def down
    # This migration can't be safely reversed because string IDs cannot be
    # converted to integers without potential data loss
    raise ActiveRecord::IrreversibleMigration
  end
end
