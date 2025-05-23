require "rails_helper"

RSpec.describe Form, type: :model do
  describe "validations" do
    it "requires a name" do
      form = Form.new(button_text: "Submit")
      expect(form).not_to be_valid
      expect(form.errors[:name]).to include("can't be blank")
    end

    it "requires a button text" do
      form = Form.new(name: "Test Form")
      expect(form).not_to be_valid
      expect(form.errors[:button_text]).to include("can't be blank")
    end

    it "validates email format" do
      form = Form.new(
        name: "Test Form",
        button_text: "Submit",
        target_email_address: "invalid-email"
      )
      expect(form).not_to be_valid
      expect(form.errors[:target_email_address]).to include("is invalid")
    end

    it "allows blank email" do
      form = Form.new(
        name: "Test Form",
        button_text: "Submit",
        target_email_address: ""
      )
      expect(form.errors[:target_email_address]).to be_empty
    end
  end

  describe "code generation" do
    it "automatically generates a code before validation" do
      form = Form.new(
        name: "Test Form",
        button_text: "Submit"
      )
      expect(form.code).to be_nil
      form.valid?
      expect(form.code).not_to be_nil
      expect(form.code.length).to eq(12)
      expect(form.code).to eq(form.code.upcase) # Should be uppercase
    end

    it "doesn't change existing code" do
      form = Form.create!(
        name: "Test Form",
        button_text: "Submit",
        code: "ABCDEFGHIJKL"
      )

      form.name = "Updated Form"
      form.save!

      expect(form.reload.code).to eq("ABCDEFGHIJKL")
    end

    it "ensures uniqueness of codes" do
      Form.create!(
        name: "Existing Form",
        button_text: "Submit",
        code: "ABCDEFGHIJKL"
      )

      new_form = Form.new(
        name: "New Form",
        button_text: "Submit",
        code: "ABCDEFGHIJKL"
      )

      expect(new_form).not_to be_valid
      expect(new_form.errors[:code]).to include("has already been taken")
    end
  end

  describe ".find_by_code_or_id" do
    let!(:form) { Form.create!(name: "Test Form", button_text: "Submit") }

    it "finds a form by its code" do
      found_form = Form.find_by_code_or_id(form.code)
      expect(found_form).to eq(form)
    end

    it "finds a form by its ID" do
      found_form = Form.find_by_code_or_id(form.id)
      expect(found_form).to eq(form)
    end

    it "returns nil when neither code nor ID matches" do
      found_form = Form.find_by_code_or_id("NONEXISTENT")
      expect(found_form).to be_nil
    end
  end
end
