class EnsureFormCodes < ActiveRecord::Migration[7.1]
  def up
    # Get the Form model
    form_class = Class.new(ActiveRecord::Base) do
      self.table_name = "forms"
    end

    # Find all forms without a code and set one
    form_class.where("code IS NULL OR code = ''").each do |form|
      form.update_column(:code, SecureRandom.alphanumeric(12).upcase)
    end
  end

  def down
    # This migration is not reversible
  end
end
