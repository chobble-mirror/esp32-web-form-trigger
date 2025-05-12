require 'rails_helper'

RSpec.describe "Submissions", type: :request do
  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  let!(:form) do 
    Form.create!(
      background_color: "#ffffff",
      text_color: "#000000",
      button_color: "#0000ff",
      button_text_color: "#ffffff",
      button_text: "Submit",
      header_text: "Test form",
      target_email_address: "test@example.com"
    )
  end
  let!(:submission) do
    Submission.create!(
      device: device,
      form: form,
      name: "Test User",
      email_address: "test@example.com"
    )
  end
  
  describe "authorization" do
    context "when not logged in" do
      it "redirects to login for index" do
        get submissions_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects to login for show" do
        get submission_path(submission)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as non-admin user" do
      before { login_as_user }

      it "redirects to root for index" do
        get submissions_path
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root for show" do
        get submission_path(submission)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when logged in as admin user" do
      before { login_as_admin }

      it "allows access to index" do
        get submissions_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to show" do
        get submission_path(submission)
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe "public form submissions" do
    it "allows access to public form" do
      get public_form_path(form.id, device.id)
      expect(response).to have_http_status(:success)
    end

    it "allows submission creation through public form" do
      expect {
        post public_form_path(form.id, device.id), params: { 
          submission: { 
            name: "Public User",
            email_address: "public@example.com"
          } 
        }
      }.to change(Submission, :count).by(1)
      expect(response).to have_http_status(:success)
    end
  end
end