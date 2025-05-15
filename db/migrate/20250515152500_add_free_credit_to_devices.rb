class AddFreeCreditToDevices < ActiveRecord::Migration[8.0]
  def change
    add_column :devices, :free_credit, :boolean, default: false, null: false
  end
end
