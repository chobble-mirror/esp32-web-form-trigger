require "rails_helper"

RSpec.describe "PublicForms code handling", type: :request do
  include AuthHelpers

  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }

  describe "with a form that has a code" do
    let!(:form) do
      Form.create!(
        name: "Form with code",
        button_text: "Submit",
        enable_name: true,
        enable_email_address: true
      )
    end

    it "allows access to the form via its code" do
      get public_form_path(form.code, device.id)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Submit") # Check for button text instead of name
    end

    it "processes submissions successfully" do
      post public_form_path(form.code, device.id), params: {
        submission: {
          name: "Test User",
          email_address: "test@example.com"
        }
      }

      expect(response).to redirect_to(form_thanks_path(form.code, device))
      follow_redirect!

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Thank You")
    end

    it "allows returning to the form from the thanks page" do
      form.update!(start_over_button_text: "Return to Form")

      post public_form_path(form.code, device.id), params: {
        submission: {
          name: "Test User",
          email_address: "test@example.com"
        }
      }

      follow_redirect!

      expect(response.body).to include("Return to Form")
      expect(response.body).to include(public_form_path(form.code, device.id))
    end
  end

  describe "form_device_links partial" do
    let!(:form) do
      Form.create!(
        name: "Test Form",
        button_text: "Submit"
      )
    end

    it "renders correctly in the forms edit view" do
      # Log in as admin to access the forms
      login_as_admin

      # Link the form to the device
      form.devices << device

      # Visit the form edit page
      get edit_form_path(form)

      # Check that the partial renders correctly with the form code
      expect(response.body).to include(public_form_path(form.code, device.id))
    end
  end
end
