require "rails_helper"

RSpec.describe "Empty form submissions", type: :request do
  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  
  describe "form with no enabled fields" do
    let!(:form) do
      Form.create!(
        name: "Empty Form",
        button_text: "Submit",
        enable_name: false,
        enable_email_address: false,
        enable_phone: false,
        enable_address: false,
        enable_postcode: false
      )
    end
    
    it "allows submitting a form with no fields" do
      expect {
        post public_form_path(form.code, device.id)
      }.to change(Submission, :count).by(1)
      
      expect(response).to redirect_to(form_thanks_path(form.code, device))
      follow_redirect!
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "code with no enabled fields" do
    let!(:form) do
      Form.create!(
        name: "Empty Form",
        button_text: "Submit",
        enable_name: false,
        enable_email_address: false,
        enable_phone: false,
        enable_address: false,
        enable_postcode: false
      )
    end
    
    let!(:code) { Code.create!(device: device, form: form) }
    
    it "allows submitting a code form with no fields" do
      expect {
        post public_code_path(code)
      }.to change(Submission, :count).by(1)
      
      expect(response).to redirect_to(code_thanks_path(code))
      follow_redirect!
      expect(response).to have_http_status(:success)
      
      # Verify the code was claimed
      code.reload
      expect(code.claimed?).to be true
    end
  end
end