require 'rails_helper'

RSpec.describe Api::V1::CreditsController, type: :controller do
  let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  let!(:form) do
    Form.create!(
      name: "Test Form",
      button_text: "Submit",
      token_validity_seconds: 120
    )
  end

  before do
    # Associate device with form
    device.forms << form
  end

  describe "POST #claim" do
    context "with submission within token_validity_seconds" do
      it "claims the submission if it's within token validity period" do
        # Create a recent submission
        submission = Submission.create!(
          device: device,
          form: form,
          name: "Test User",
          email_address: "test@example.com",
          credit_claimed: false,
          created_at: 30.seconds.ago
        )

        post :claim, params: { device_id: device.id }, format: :json

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["source"]).to eq "submission"

        # Check that submission was claimed
        expect(submission.reload.credit_claimed).to be true
      end

      it "does not claim a submission outside token validity period" do
        # Create an older submission that's outside the validity period
        submission = Submission.create!(
          device: device,
          form: form,
          name: "Test User",
          email_address: "test@example.com",
          credit_claimed: false,
          created_at: 180.seconds.ago # Form token_validity_seconds is 120
        )

        # Set free credit to false to test fallback behavior
        device.update!(free_credit: false)

        post :claim, params: { device_id: device.id }, format: :json

        # Should fail since submission is too old and no free credit
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false

        # Check that submission was not claimed
        expect(submission.reload.credit_claimed).to be false
      end
    end

    context "with different token_validity_seconds for multiple forms" do
      let!(:form2) do
        Form.create!(
          name: "Test Form 2",
          button_text: "Submit",
          token_validity_seconds: 300 # Longer validity period
        )
      end

      before do
        device.forms << form2
      end

      it "respects each form's token_validity_seconds setting" do
        # Create submissions for both forms
        submission1 = Submission.create!(
          device: device,
          form: form,
          name: "User 1",
          email_address: "user1@example.com",
          credit_claimed: false,
          created_at: 200.seconds.ago # Too old for form1 (120s)
        )

        submission2 = Submission.create!(
          device: device,
          form: form2,
          name: "User 2",
          email_address: "user2@example.com",
          credit_claimed: false,
          created_at: 200.seconds.ago # Still valid for form2 (300s)
        )

        post :claim, params: { device_id: device.id }, format: :json

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["source"]).to eq "submission"

        # First submission should not be claimed (too old)
        expect(submission1.reload.credit_claimed).to be false
        # Second submission should be claimed (within validity period)
        expect(submission2.reload.credit_claimed).to be true
      end
    end
  end
end
