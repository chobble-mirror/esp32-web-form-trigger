require "rails_helper"

RSpec.describe Code, type: :model do
  let(:device) { Device.create!(name: "Test Device") }
  let(:form) { Form.create!(name: "Test Form", button_text: "Submit") }

  describe "associations" do
    it "belongs to a device" do
      code = Code.new(form: form)
      expect(code).not_to be_valid

      code.device = device
      expect(code).to be_valid
    end

    it "belongs to a form" do
      code = Code.new(device: device)
      expect(code).not_to be_valid

      code.form = form
      expect(code).to be_valid
    end
  end

  describe "validations" do
    it "generates an ID if none is provided" do
      code = Code.new(device: device, form: form)
      expect(code.id).to be_nil  # Before validation, ID is nil

      code.valid?  # Trigger the validations
      expect(code.id).not_to be_nil  # After validation, ID should be generated
      expect(code.id.length).to eq(12)
    end

    it "requires a unique ID" do
      code1 = Code.create!(device: device, form: form)
      code2 = Code.new(device: device, form: form, id: code1.id)
      expect(code2).not_to be_valid
      expect(code2.errors[:id]).to include("has already been taken")
    end

    it "requires ID to be 12 characters" do
      code = Code.new(device: device, form: form)
      code.id = "ABC"
      expect(code).not_to be_valid
      expect(code.errors[:id]).to include("is the wrong length (should be 12 characters)")
    end
  end

  describe "creation" do
    it "generates a random 12-character uppercase ID if none provided" do
      code = Code.new(device: device, form: form)
      code.save!

      expect(code.id).to be_present
      expect(code.id.length).to eq(12)
      expect(code.id).to match(/^[A-Z0-9]{12}$/)
    end
  end

  describe "claim!" do
    it "marks the code as claimed" do
      code = Code.create!(device: device, form: form)
      expect(code.claimed?).to be false

      code.claim!
      expect(code.claimed?).to be true
      expect(code.claimed_at).to be_present
    end
  end
end
