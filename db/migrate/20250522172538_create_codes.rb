class CreateCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :codes do |t|
      t.string :id
      t.references :device, null: false, foreign_key: true
      t.references :form, null: false, foreign_key: true
      t.datetime :claimed_at

      t.timestamps
    end
  end
end
