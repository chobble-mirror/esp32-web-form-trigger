module SubmissionProcessing
  extend ActiveSupport::Concern

  def process_submission
    build_submission

    return handle_already_claimed_code if code_already_claimed?

    if @submission.save
      handle_successful_submission
    else
      render "public_forms/show", status: :unprocessable_entity
    end
  end

  private

  def build_submission
    @submission = @form.submissions.new(device: @device)
    @submission.assign_attributes(submission_params) if params[:submission].present?
    @submission.user = current_user if current_user
  end

  def code?
    defined?(@code) && @code
  end

  def code_already_claimed?
    code? && @code.claimed?
  end

  def handle_already_claimed_code
    @submission.errors.add(:base, "This code has already been used")
    render "public_forms/show", status: :unprocessable_entity
  end

  def handle_successful_submission
    claim_code_if_present
    send_submission_email
    redirect_to_thanks_page
  end

  def claim_code_if_present
    @code.claim! if code?
  end

  def redirect_to_thanks_page
    if code?
      redirect_to code_thanks_path(@code)
    else
      redirect_to form_thanks_path(@form.code, @device)
    end
  end

  def send_submission_email
    return unless @form.target_email_address.present?

    begin
      SubmissionMailer.new_submission(@submission).deliver_later
    rescue => e
      log_email_error(e)
    end
  end

  def log_email_error(error)
    Rails.logger.error "Failed to queue submission email: #{error.message}"
    @submission.mark_as_failed! if @submission.respond_to?(:mark_as_failed!)
  end

  def check_form_access
    return unless @form.require_login && !logged_in?

    store_location
    redirect_to login_path, alert: "You need to log in to access this form"
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
      {}
    end
  end
end