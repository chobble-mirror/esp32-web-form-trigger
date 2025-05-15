module Api
  module V1
    class CreditsController < ApplicationController
      # Skip CSRF protection and login for API endpoints
      skip_before_action :verify_authenticity_token
      skip_before_action :require_login

      # Check for available credits
      def check
        device = Device.find_by(id: params[:device_id])

        if !device
          render json: {error: "Device not found"}, status: :not_found
          return
        end

        # Update last_heard_from timestamp
        device.update_last_heard_from

        unclaimed_submissions = Submission.unclaimed.for_device(device.id)
        submission_credits = unclaimed_submissions.count
        free_credit_available = device.free_credit
        total_credits = submission_credits + (free_credit_available ? 1 : 0)

        render json: {
          device_id: device.id,
          credits_available: total_credits,
          submission_credits: submission_credits,
          free_credit_available: free_credit_available
        }
      end

      # Claim a credit
      def claim
        device = Device.find_by(id: params[:device_id])

        if !device
          render json: {error: "Device not found"}, status: :not_found
          return
        end

        # Update last_heard_from timestamp
        device.update_last_heard_from

        # First try to claim a normal submission credit
        submission = Submission.unclaimed.for_device(device.id).first

        if submission
          submission.mark_as_claimed!
          render json: {success: true, message: "Credit claimed successfully", source: "submission"}
          return
        end

        # If no submission credits, try to claim a free credit
        if device.claim_free_credit
          render json: {success: true, message: "Free credit claimed successfully", source: "free_credit"}
        else
          render json: {success: false, message: "No credits available"}, status: :not_found
        end
      end
    end
  end
end
