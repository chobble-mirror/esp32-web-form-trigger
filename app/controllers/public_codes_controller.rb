class PublicCodesController < ApplicationController
  include SubmissionProcessing

  skip_before_action :require_login
  before_action :set_code
  before_action :set_form_and_device
  before_action :check_form_access, only: [:show, :create]
  layout "public_forms"

  def show
    # If code has already been claimed, show the thank you page
    if @code.claimed?
      render "public_forms/thanks"
      return
    end

    @submission = Submission.new
    render "public_forms/show"
  end

  def thanks
    render "public_forms/thanks"
  end

  def create
    process_submission
  end

  private

  def set_code
    @code = Code.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Invalid code"
    redirect_to root_path
  end

  def set_form_and_device
    @form = @code.form
    @device = @code.device
  end
end
