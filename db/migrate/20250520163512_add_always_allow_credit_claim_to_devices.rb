class AddAlwaysAllowCreditClaimToDevices < ActiveRecord::Migration[8.0]
  def change
    add_column :devices, :always_allow_credit_claim, :boolean, default: false, null: false
  end
end
