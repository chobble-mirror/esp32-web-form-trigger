class CreateForms < ActiveRecord::Migration[8.0]
  def change
    create_table :forms do |t|
      t.string :background_color
      t.string :text_color
      t.string :button_color
      t.string :button_text_color
      t.string :button_text
      t.text :header_text
      t.boolean :enable_name, default: true
      t.boolean :enable_email_address, default: true
      t.boolean :enable_phone, default: false
      t.boolean :enable_address, default: false
      t.boolean :enable_postcode, default: false
      t.text :terms_and_conditions
      t.text :thank_you_text
      t.string :target_email_address
      
      t.timestamps
    end
  end
end
