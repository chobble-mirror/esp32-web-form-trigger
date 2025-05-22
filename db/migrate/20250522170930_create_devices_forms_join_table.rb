class CreateDevicesFormsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :devices, :forms do |t|
      t.index [:device_id, :form_id], unique: true
      t.index [:form_id, :device_id]
    end
  end
end
