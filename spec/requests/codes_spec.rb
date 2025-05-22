require "rails_helper"

RSpec.describe "Codes", type: :request do
  include AuthHelpers

  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  let!(:form) { Form.create!(name: "Test Form", button_text: "Submit") }

  describe "POST /codes (create)" do
    context "when logged in as admin" do
      before { login_as_admin }

      it "creates a new code with valid parameters" do
        expect {
          post codes_path, params: {code: {device_id: device.id, form_id: form.id}, count: 1}
        }.to change(Code, :count).by(1)

        expect(response).to redirect_to(codes_path)
        expect(flash[:notice]).to include("Successfully created 1 code")
      end

      it "creates multiple codes when count is specified" do
        expect {
          post codes_path, params: {code: {device_id: device.id, form_id: form.id}, count: 3}
        }.to change(Code, :count).by(3)

        expect(response).to redirect_to(codes_path)
        expect(flash[:notice]).to include("Successfully created 3 code")
      end

      it "handles non-existent device gracefully" do
        expect {
          post codes_path, params: {code: {device_id: "nonexistent", form_id: form.id}, count: 1}
        }.not_to change(Code, :count)

        expect(response).to redirect_to(new_code_path)
        expect(flash[:error]).to include("Device not found")
      end

      it "handles non-existent form gracefully" do
        expect {
          post codes_path, params: {code: {device_id: device.id, form_id: "nonexistent"}, count: 1}
        }.not_to change(Code, :count)

        expect(response).to redirect_to(new_code_path)
        expect(flash[:error]).to include("Form not found")
      end
    end
  end
end
