require "rails_helper"

RSpec.describe "PublicCodes", type: :request do
  include AuthHelpers
  
  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  let!(:form) { 
    Form.create!(
      name: "Test Form", 
      button_text: "Submit",
      enable_name: true,
      name_field_label: "Name",
      enable_email_address: true,
      email_field_label: "Email"
    ) 
  }
  let!(:code) { Code.create!(device: device, form: form) }
  
  describe "GET /code/:id" do
    it "displays the form successfully" do
      get public_code_path(code)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(form.name_field_label)
      expect(response.body).to include(form.email_field_label)
    end

    it "uses the public_forms layout without admin navigation" do
      get public_code_path(code)
      expect(response).to have_http_status(:success)
      expect(response).to render_template("layouts/public_forms")
      expect(response.body).not_to include("Devices")
      expect(response.body).not_to include("Log Out")
    end

    it "shows the thank you page if the code has already been claimed without refresh or start over button" do
      # Set a start over button text on the form
      form.update!(start_over_button_text: "Start Again")

      # Mark the code as claimed
      code.claim!

      # Try to access the code
      get public_code_path(code)

      # Should show the thank you page
      expect(response).to have_http_status(:success)
      expect(response).to render_template('public_forms/thanks')

      # Should show typical thank you page content
      expect(response.body).to include("Thank You")

      # Should NOT include refresh meta tag or start over button
      expect(response.body).not_to include('meta http-equiv="refresh"')
      expect(response.body).not_to include(form.start_over_button_text)
    end
    
    context "when form requires login" do
      before do
        form.update!(require_login: true)
      end
      
      it "redirects to login if not logged in" do
        get public_code_path(code)
        expect(response).to redirect_to(login_path)
      end
      
      it "displays the form when logged in" do
        login_as_user
        get public_code_path(code)
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe "POST /code/:id" do
    let(:valid_params) { 
      { 
        submission: { 
          name: "Test User", 
          email_address: "test@example.com" 
        } 
      } 
    }
    
    it "creates a submission and marks the code as claimed" do
      expect {
        post public_code_path(code), params: valid_params
      }.to change(Submission, :count).by(1)

      # Reload the code to check if it was claimed
      code.reload
      expect(code.claimed?).to be true
      expect(code.claimed_at).to be_present
      expect(code.claimed_at).to be_within(5.seconds).of(Time.current)

      # Check if we were redirected to the thanks page
      expect(response).to redirect_to(code_thanks_path(code))
    end

    it "prevents using a code that has already been claimed" do
      # First claim the code
      post public_code_path(code), params: valid_params
      expect(code.reload.claimed?).to be true

      # Try to use it again
      expect {
        post public_code_path(code), params: valid_params.merge(
          submission: { name: "Another User", email_address: "another@example.com" }
        )
      }.not_to change(Submission, :count)

      # Should show an error message
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("This code has already been used")
    end
    
    it "renders the form again on validation errors" do
      post public_code_path(code), params: { submission: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("prohibited this submission from being saved")
    end
  end
  
  describe "GET /code/:id/thanks" do
    it "displays the thanks page" do
      get code_thanks_path(code)
      expect(response).to have_http_status(:success)
    end

    it "includes refresh meta tag and start over button for unclaimed codes" do
      # Set a start over button text on the form
      form.update!(start_over_button_text: "Start Again")

      # Access thanks page for unclaimed code
      get code_thanks_path(code)

      # Should include refresh meta tag and start over button
      expect(response.body).to include('meta http-equiv="refresh"')
      expect(response.body).to include(form.start_over_button_text)
    end
  end
end