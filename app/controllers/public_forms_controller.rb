class PublicFormsController < ApplicationController
  # Skip login for public form views
  skip_before_action :require_login
  before_action :set_form_and_device
  layout "public_forms"

  def show
    @submission = Submission.new
  end

  def create
    @submission = @form.submissions.new(submission_params)
    @submission.device = @device

    if @submission.save
      # Send the submission email
      begin
        SubmissionMailer.new_submission(@submission).deliver_later
        # Email will be sent asynchronously, so we mark it as pending
        # It will be updated when the job completes
      rescue => e
        # Log the error but continue with the form submission
        Rails.logger.error "Failed to queue submission email: #{e.message}"
        @submission.mark_as_failed!
      end

      render :thanks
    else
      render :show, status: :unprocessable_entity
    end
  end

  def thanks
    # This is rendered after successful form submission
  end

  private

  def set_form_and_device
    @form = Form.find(params[:form_id])
    @device = Device.find(params[:device_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Form or device not found"
  end

  def submission_params
    params.require(:submission).permit(
      :name,
      :email_address,
      :phone,
      :address,
      :postcode
    )
  end
end
