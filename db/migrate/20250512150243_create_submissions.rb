class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.references :form, null: false, foreign_key: true
      t.references :device, null: false, foreign_key: true
      t.string :name
      t.string :email_address
      t.string :phone
      t.text :address
      t.string :postcode
      t.boolean :credit_claimed, default: false
      t.string :email_status, default: "pending"
      t.datetime :emailed_at
      
      t.timestamps
    end
    
    add_index :submissions, [:device_id, :credit_claimed], name: "index_submissions_on_device_and_credit"
  end
end
