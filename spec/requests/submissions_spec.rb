require "rails_helper"

RSpec.describe "Submissions", type: :request do
  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  let!(:form) do
    Form.create!(
      name: "Test Form",
      background_color: "#ffffff",
      text_color: "#000000",
      button_color: "#0000ff",
      button_text_color: "#ffffff",
      button_text: "Submit",
      header_text: "Test form",
      target_email_address: "test@example.com",
      token_validity_seconds: 120
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
    it "allows access to public form using form code" do
      get public_form_path(form.code, device.id)
      expect(response).to have_http_status(:success)
    end

    it "allows submission creation through public form using form code" do
      expect {
        post public_form_path(form.code, device.id), params: {
          submission: {
            name: "Public User",
            email_address: "public@example.com"
          }
        }
      }.to change(Submission, :count).by(1)
      expect(response).to redirect_to(form_thanks_path(form.code, device))
    end

    it "shows the thank you page after form submission" do
      post public_form_path(form.code, device.id), params: {
        submission: {
          name: "Public User",
          email_address: "public@example.com"
        }
      }
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Thank You")
      expect(response.body).to include("Your submission has been received")
    end

    it "shows the start over button when configured" do
      form.update!(start_over_button_text: "Start Again")
      post public_form_path(form.code, device.id), params: {
        submission: {
          name: "Start Over User",
          email_address: "startover@example.com"
        }
      }
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Start Again")
      expect(response.body).to include(public_form_path(form.code, device))
    end

    it "shows custom thank you text when present" do
      form.update!(thank_you_text: "Custom thank you message")
      post public_form_path(form.code, device.id), params: {
        submission: {
          name: "Custom Thanks User",
          email_address: "custom@example.com"
        }
      }
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Custom thank you message")
      expect(response.body).not_to include("Your submission has been received")
    end

    it "does not send emails for forms without target_email_address" do
      form_without_email = Form.create!(
        name: "Form Without Email",
        button_text: "Submit",
        target_email_address: ""
      )

      # Should not attempt to deliver email
      expect(SubmissionMailer).not_to receive(:new_submission)

      post public_form_path(form_without_email.code, device.id), params: {
        submission: {
          name: "No Email User",
          email_address: "no-email@example.com"
        }
      }

      expect(response).to redirect_to(form_thanks_path(form_without_email.code, device))
    end

    context "with a form that requires login" do
      before do
        form.update!(require_login: true)
      end

      it "redirects to login when not logged in" do
        get public_form_path(form.code, device.id)
        expect(response).to redirect_to(login_path)
      end

      it "allows access when logged in" do
        login_as_admin
        get public_form_path(form.code, device.id)
        expect(response).to have_http_status(:success)
      end

      it "associates submission with logged in user" do
        admin = login_as_admin

        expect {
          post public_form_path(form.code, device.id), params: {
            submission: {
              name: "Logged In User",
              email_address: "loggedin@example.com"
            }
          }
        }.to change(Submission, :count).by(1)

        expect(Submission.last.user).to eq(admin)
      end

      it "shows the thank you page after logged-in submission" do
        login_as_admin
        post public_form_path(form.code, device.id), params: {
          submission: {
            name: "Logged In User",
            email_address: "loggedin@example.com"
          }
        }
        follow_redirect!
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Thank You")
      end
    end
  end
end
