require "rails_helper"

RSpec.describe Device, type: :model do
  describe "validations" do
    it "is valid with a name" do
      device = Device.new(name: "Test Device")
      expect(device).to be_valid
    end

    it "is invalid without a name" do
      device = Device.new(name: nil)
      expect(device).not_to be_valid
      expect(device.errors[:name]).to include("can't be blank")
    end

    it "generates a 12-character ID before validation" do
      device = Device.new(name: "Test Device")
      device.valid?
      expect(device.id).to be_present
      expect(device.id.length).to eq(12)
    end

    it "validates that ID is 12 characters" do
      device = Device.new(name: "Test Device", id: "123")
      expect(device).not_to be_valid
      expect(device.errors[:id]).to include("is the wrong length (should be 12 characters)")
    end
  end

  describe "ID generation" do
    it "generates unique IDs for different devices" do
      device1 = Device.create!(name: "Test Device 1")
      device2 = Device.create!(name: "Test Device 2")
      expect(device1.id).not_to eq(device2.id)
    end

    it "does not overwrite an existing ID" do
      custom_id = "ABCDEFGHIJKL"
      device = Device.new(name: "Test Device", id: custom_id)
      device.valid?
      expect(device.id).to eq(custom_id)
    end
  end
end
