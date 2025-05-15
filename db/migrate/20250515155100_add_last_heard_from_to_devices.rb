class AddLastHeardFromToDevices < ActiveRecord::Migration[8.0]
  def change
    add_column :devices, :last_heard_from, :datetime
  end
end
