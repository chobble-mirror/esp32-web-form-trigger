class CreateCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :codes, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.references :device, null: false, foreign_key: true, type: :string
      t.references :form, null: false, foreign_key: true
      t.datetime :claimed_at

      t.timestamps
    end

    add_index :codes, :claimed_at
  end
end
