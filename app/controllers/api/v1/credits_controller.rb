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

        unclaimed_submissions = Submission.unclaimed.for_device(device.id)

        render json: {
          device_id: device.id,
          credits_available: unclaimed_submissions.count
        }
      end

      # Claim a credit
      def claim
        device = Device.find_by(id: params[:device_id])

        if !device
          render json: {error: "Device not found"}, status: :not_found
          return
        end

        submission = Submission.unclaimed.for_device(device.id).first

        if submission
          submission.mark_as_claimed!
          render json: {success: true, message: "Credit claimed successfully"}
        else
          render json: {success: false, message: "No credits available"}, status: :not_found
        end
      end
    end
  end
end
