require "rails_helper"

RSpec.describe "API V1 Credits", type: :request do
  # Using a let block for device but creating it only when needed
  let(:device) { Device.create!(name: "Test Device", location: "Test Location") }
  
  # Default form with all validations disabled and reasonable token validity
  let(:form_attributes) { {
    name: "Test Form",
    token_validity_seconds: 3600,
    button_text: "Submit",
    enable_email_address: false,
    enable_name: false,
    enable_phone: false,
    enable_address: false,
    enable_postcode: false
  } }

  describe "POST /api/v1/credits/claim" do
    context "with a valid device_id and an unclaimed submission" do
      it "claims the submission credit and returns success" do
        # Create form and associate with device
        form = Form.create!(form_attributes)
        device.forms << form
        
        # Create a submission within the validity period
        submission = Submission.create!(name: "Test User", device: device, form: form, credit_claimed: false)
        
        expect {
          post "/api/v1/credits/claim", params: { device_id: device.id }
        }.to change { submission.reload.credit_claimed }.from(false).to(true)

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include(
          "success" => true,
          "message" => "Credit claimed successfully",
          "source" => "submission"
        )
      end

      it "updates the device's last_heard_from timestamp" do
        # Simple form setup
        form = Form.create!(form_attributes)
        device.forms << form
        
        expect {
          post "/api/v1/credits/claim", params: { device_id: device.id }
        }.to change { device.reload.last_heard_from }
        
        # The timestamp should be within the last minute
        expect(device.reload.last_heard_from).to be_within(1.minute).of(Time.current)
      end
    end

    context "with submissions outside the token validity period" do
      it "only claims submissions within the token validity period" do
        # Create a form with short validity period
        short_form = Form.create!(form_attributes.merge(
          name: "Short Validity Form", 
          token_validity_seconds: 30
        ))
        device.forms << short_form
        
        # Create an old submission that should be ignored
        old_submission = Submission.create!(
          name: "Old User", 
          device: device, 
          form: short_form, 
          credit_claimed: false
        )
        old_submission.update_column(:created_at, 1.hour.ago)
        
        # Create a recent submission that should be claimed
        recent_submission = Submission.create!(
          name: "Recent User", 
          device: device, 
          form: short_form, 
          credit_claimed: false
        )
        
        post "/api/v1/credits/claim", params: { device_id: device.id }
        
        # Recent submission should be claimed
        expect(recent_submission.reload.credit_claimed).to eq(true)
        
        # Old submission should not be claimed
        expect(old_submission.reload.credit_claimed).to eq(false)
        
        expect(JSON.parse(response.body)["source"]).to eq("submission")
      end
    end

    context "with different forms having different token validity periods" do
      it "respects each form's token validity period" do
        # Create forms with different validity periods
        short_form = Form.create!(form_attributes.merge(
          name: "Short Validity Form", 
          token_validity_seconds: 30
        ))
        
        long_form = Form.create!(form_attributes.merge(
          name: "Long Validity Form", 
          token_validity_seconds: 86400
        ))
        
        # Associate both forms with the device
        device.forms << short_form
        device.forms << long_form
        
        # Create submissions for both forms, both 1 hour old
        old_short_submission = Submission.create!(
          name: "Old Short", 
          device: device, 
          form: short_form, 
          credit_claimed: false
        )
        old_short_submission.update_column(:created_at, 1.hour.ago)
        
        old_long_submission = Submission.create!(
          name: "Old Long", 
          device: device, 
          form: long_form, 
          credit_claimed: false
        )
        old_long_submission.update_column(:created_at, 1.hour.ago)
        
        post "/api/v1/credits/claim", params: { device_id: device.id }
        
        # The long form submission should be claimed (it's within 24h validity)
        expect(old_long_submission.reload.credit_claimed).to eq(true)
        
        # The short form submission should not be claimed (it's outside 30s validity)
        expect(old_short_submission.reload.credit_claimed).to eq(false)
      end
    end

    context "with a valid device_id and a free credit available" do
      it "claims the free credit and returns success" do
        # Update device to have a free credit
        device.update!(free_credit: true)
        
        expect {
          post "/api/v1/credits/claim", params: { device_id: device.id }
        }.to change { device.reload.free_credit }.from(true).to(false)

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include(
          "success" => true,
          "message" => "Free credit claimed successfully",
          "source" => "free_credit"
        )
      end
    end

    context "with a valid device_id and always_allow_credit_claim set to true" do
      it "returns success without changing any credits" do
        # Set up a device with always_allow_credit_claim
        device.update!(always_allow_credit_claim: true)
        
        # Create a form and a submission
        form = Form.create!(form_attributes)
        device.forms << form
        submission = Submission.create!(
          name: "Test User", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        
        # Also set free_credit to true, but it should not be claimed
        device.update!(free_credit: true)
        
        # Neither the submission nor the free credit should be claimed
        expect {
          post "/api/v1/credits/claim", params: { device_id: device.id }
        }.not_to change { submission.reload.credit_claimed }
        
        expect {
          post "/api/v1/credits/claim", params: { device_id: device.id }
        }.not_to change { device.reload.free_credit }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include(
          "success" => true,
          "message" => "Credit claimed successfully",
          "source" => "always_allow"
        )
      end
    end

    context "with a valid device_id but no credits available" do
      it "returns an error" do
        # Set up device with no credits
        device.update!(free_credit: false)
        
        post "/api/v1/credits/claim", params: { device_id: device.id }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include(
          "success" => false,
          "message" => "No credits available"
        )
      end
    end

    context "with an invalid device_id" do
      it "returns a not found error" do
        post "/api/v1/credits/claim", params: { device_id: "nonexistent" }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include(
          "error" => "Device not found"
        )
      end
    end

    context "with multiple sources of credits" do
      it "claims the submission credit first" do
        # Create form and submissions
        form = Form.create!(form_attributes)
        device.forms << form
        
        # Set up both submission and free credit
        device.update!(free_credit: true)
        submission1 = Submission.create!(
          name: "User 1", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        submission2 = Submission.create!(
          name: "User 2", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        
        # First submission should be claimed first
        post "/api/v1/credits/claim", params: { device_id: device.id }
        
        # The first submission should be claimed
        expect(submission1.reload.credit_claimed).to eq(true)
        
        # Free credit and second submission should not be claimed yet
        expect(device.reload.free_credit).to eq(true)
        expect(submission2.reload.credit_claimed).to eq(false)
        
        expect(JSON.parse(response.body)["source"]).to eq("submission")
      end

      it "claims submission credits before free credits" do
        # Set up both submission and free credit
        form = Form.create!(form_attributes)
        device.forms << form
        device.update!(free_credit: true)
        
        submission1 = Submission.create!(
          name: "User 1", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        submission2 = Submission.create!(
          name: "User 2", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        
        # Claim first submission
        post "/api/v1/credits/claim", params: { device_id: device.id }
        expect(submission1.reload.credit_claimed).to eq(true)
        
        # Claim second submission
        post "/api/v1/credits/claim", params: { device_id: device.id }
        expect(submission2.reload.credit_claimed).to eq(true)
        
        # Free credit should still not be claimed
        expect(device.reload.free_credit).to eq(true)
        
        # Claim free credit last
        post "/api/v1/credits/claim", params: { device_id: device.id }
        expect(device.reload.free_credit).to eq(false)
        
        expect(JSON.parse(response.body)["source"]).to eq("free_credit")
      end
    end

    context "when credits are exhausted" do
      it "returns error after all credits are claimed" do
        # Set up a form and submission with free credit
        form = Form.create!(form_attributes)
        device.forms << form
        device.update!(free_credit: true)
        
        submission = Submission.create!(
          name: "Test User", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        
        # Claim submission credit
        post "/api/v1/credits/claim", params: { device_id: device.id }
        expect(submission.reload.credit_claimed).to eq(true)
        
        # Claim free credit
        post "/api/v1/credits/claim", params: { device_id: device.id }
        expect(device.reload.free_credit).to eq(false)
        
        # Attempt to claim when no credits are available
        post "/api/v1/credits/claim", params: { device_id: device.id }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include(
          "success" => false,
          "message" => "No credits available"
        )
      end
    end
  end

  describe "GET /api/v1/credits/check" do
    context "with a valid device_id" do
      it "returns the correct credit information with no credits" do
        get "/api/v1/credits/check", params: { device_id: device.id }
        
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to include(
          "device_id" => device.id,
          "credits_available" => 0,
          "submission_credits" => 0,
          "free_credit_available" => false,
          "always_allow_credit_claim" => false
        )
      end
      
      it "counts unclaimed submissions correctly" do
        # Create form and submissions
        form = Form.create!(form_attributes)
        device.forms << form
        
        # Create two submissions, one claimed and one unclaimed
        Submission.create!(
          name: "User 1", 
          device: device, 
          form: form, 
          credit_claimed: true
        )
        Submission.create!(
          name: "User 2", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        
        get "/api/v1/credits/check", params: { device_id: device.id }
        
        expect(JSON.parse(response.body)).to include(
          "submission_credits" => 1,
          "credits_available" => 1
        )
      end
      
      it "includes free credit in the total" do
        device.update!(free_credit: true)
        
        get "/api/v1/credits/check", params: { device_id: device.id }
        
        expect(JSON.parse(response.body)).to include(
          "free_credit_available" => true,
          "credits_available" => 1
        )
      end
      
      it "combines submission and free credits" do
        # Set up form, submission, and free credit
        form = Form.create!(form_attributes)
        device.forms << form
        device.update!(free_credit: true)
        
        Submission.create!(
          name: "Test User", 
          device: device, 
          form: form, 
          credit_claimed: false
        )
        
        get "/api/v1/credits/check", params: { device_id: device.id }
        
        expect(JSON.parse(response.body)).to include(
          "submission_credits" => 1,
          "free_credit_available" => true,
          "credits_available" => 2
        )
      end
      
      it "returns always 1 credit when always_allow_credit_claim is true" do
        device.update!(always_allow_credit_claim: true)
        
        get "/api/v1/credits/check", params: { device_id: device.id }
        
        expect(JSON.parse(response.body)).to include(
          "always_allow_credit_claim" => true,
          "credits_available" => 1
        )
      end
      
      it "updates the device's last_heard_from timestamp" do
        expect {
          get "/api/v1/credits/check", params: { device_id: device.id }
        }.to change { device.reload.last_heard_from }
        
        expect(device.reload.last_heard_from).to be_within(1.minute).of(Time.current)
      end
    end
    
    context "with an invalid device_id" do
      it "returns a not found error" do
        get "/api/v1/credits/check", params: { device_id: "nonexistent" }
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include(
          "error" => "Device not found"
        )
      end
    end
  end
end