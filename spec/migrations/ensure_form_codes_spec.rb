require "rails_helper"

RSpec.describe "EnsureFormCodes migration", type: :migration do
  let(:migration_path) { File.join(Rails.root, "db/migrate/20250523081500_ensure_form_codes.rb") }
  let(:migration_class) { "EnsureFormCodes" }

  # Helper to create a form directly bypassing validations
  def create_form_without_code(attrs = {})
    attrs = {name: "Form without code", button_text: "Submit"}.merge(attrs)

    # Override the generate_code callback temporarily
    Form.skip_callback(:validation, :before, :generate_code, raise: false)

    form = Form.create!(attrs)

    # Reset the code to nil
    form.update_column(:code, nil)

    Form.set_callback(:validation, :before, :generate_code)

    form.reload
  end

  it "adds codes to all forms that don't have one" do
    # Create a form with a nil code
    form1 = create_form_without_code(name: "Form with nil code")
    expect(form1.code).to be_nil

    # Create a form with an empty code
    form2 = create_form_without_code(name: "Form with empty code")
    form2.update_column(:code, "")
    form2.reload
    expect(form2.code).to eq("")

    # Create a form with a valid code
    form3 = Form.create!(name: "Form with code", button_text: "Submit")
    original_code = form3.code
    expect(original_code).not_to be_nil

    # Load and run the migration
    require migration_path
    migration = migration_class.constantize.new
    migration.up

    # Check that forms have codes now
    form1.reload
    expect(form1.code).not_to be_nil
    expect(form1.code.length).to eq(12)

    form2.reload
    expect(form2.code).not_to be_nil
    expect(form2.code.length).to eq(12)

    # Check that existing codes are preserved
    form3.reload
    expect(form3.code).to eq(original_code)
  end
end
