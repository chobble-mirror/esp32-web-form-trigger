class AddCustomFieldLabelsAndPlaceholders < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :name_field_label, :string, default: "Name"
    add_column :forms, :name_field_placeholder, :string, default: ""

    add_column :forms, :email_field_label, :string, default: "Email Address"
    add_column :forms, :email_field_placeholder, :string, default: ""

    add_column :forms, :phone_field_label, :string, default: "Phone"
    add_column :forms, :phone_field_placeholder, :string, default: ""

    add_column :forms, :address_field_label, :string, default: "Address"
    add_column :forms, :address_field_placeholder, :string, default: ""

    add_column :forms, :postcode_field_label, :string, default: "Postcode"
    add_column :forms, :postcode_field_placeholder, :string, default: ""
  end
end
