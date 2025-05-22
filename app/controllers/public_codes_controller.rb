class PublicCodesController < ApplicationController
  skip_before_action :require_login
  before_action :set_code
  layout "public_forms"
  
  def show
    if @code.form.require_login? && !logged_in?
      store_location
      redirect_to login_path
      return
    end

    # If code has already been claimed, show the thank you page
    if @code.claimed?
      # Still set the form and device for the thank you page
      @form = @code.form
      @device = @code.device
      render 'public_forms/thanks'
      return
    end

    @form = @code.form
    @device = @code.device
    @submission = Submission.new
    render 'public_forms/show'
  end
  
  def thanks
    @form = @code.form
    @device = @code.device
    render 'public_forms/thanks'
  end

  def create
    @form = @code.form
    @device = @code.device
    @submission = @form.submissions.new(submission_params)
    @submission.device = @device

    # Check if the code has already been claimed
    if @code.claimed?
      @submission.errors.add(:base, "This code has already been used")
      return render 'public_forms/show', status: :unprocessable_entity
    end

    # Associate the submission with the current user if logged in
    @submission.user = current_user if current_user

    if @submission.save
      # Mark the code as claimed
      @code.claim!

      # Send the submission email only if target_email_address is present
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

      # Redirect to thanks page instead of rendering
      redirect_to code_thanks_path(@code)
    else
      render 'public_forms/show', status: :unprocessable_entity
    end
  end
  
  private

  def set_code
    @code = Code.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Invalid code"
    redirect_to root_path
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