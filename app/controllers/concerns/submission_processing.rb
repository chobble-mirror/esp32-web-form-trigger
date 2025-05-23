module SubmissionProcessing
  extend ActiveSupport::Concern

  # Common method to process a submission for either form or code
  def process_submission
    # Initialize a new submission, handling the case where no fields are enabled
    @submission = @form.submissions.new
    @submission.device = @device

    # Only attempt to update with submission params if they exist in the request
    # This handles forms that have no enabled fields
    @submission.assign_attributes(submission_params) if params[:submission].present?

    # Associate the submission with the current user if logged in
    @submission.user = current_user if current_user

    # Check if this is a code submission and if the code has already been claimed
    if defined?(@code) && @code && @code.claimed?
      @submission.errors.add(:base, "This code has already been used")
      return render "public_forms/show", status: :unprocessable_entity
    end

    if @submission.save
      # Mark the code as claimed if this is a code submission
      @code.claim! if defined?(@code) && @code

      # Send the submission email only if target_email_address is present
      send_submission_email

      # Redirect to thanks page instead of rendering
      # This prevents form resubmission on refresh
      if defined?(@code) && @code
        redirect_to code_thanks_path(@code)
      else
        redirect_to form_thanks_path(@form.code, @device)
      end
    else
      render "public_forms/show", status: :unprocessable_entity
    end
  end

  def send_submission_email
    if @form.target_email_address.present?
      begin
        SubmissionMailer.new_submission(@submission).deliver_later
        # Email will be sent asynchronously, so we mark it as pending
        # It will be updated when the job completes
      rescue => e
        # Log the error but continue with the form submission
        Rails.logger.error "Failed to queue submission email: #{e.message}"
        @submission.mark_as_failed! if @submission.respond_to?(:mark_as_failed!)
      end
    end
  end

  def check_form_access
    # Redirect to login if the form requires login and user is not logged in
    if @form.require_login && !logged_in?
      store_location # Store the current URL to redirect back after login
      redirect_to login_path, alert: "You need to log in to access this form"
    end
  end

  def submission_params
    if params[:submission].present?
      params.require(:submission).permit(
        :name,
        :email_address,
        :phone,
        :address,
        :postcode
      )
    else
      # Return an empty hash if there are no submission parameters
      {}
    end
  end
end