class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices, id: false do |t|
      t.string :id, limit: 12, primary_key: true, null: false
      t.string :name, null: false
      t.string :location

      t.timestamps
    end
  end
end
