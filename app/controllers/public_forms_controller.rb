class PublicFormsController < ApplicationController
  require 'rqrcode'

  # Skip login for public form views, but check if the form requires login
  skip_before_action :require_login
  before_action :set_form_and_device, except: [:qr_code]
  before_action :set_form_and_device_for_qr, only: [:qr_code]
  before_action :check_form_access, only: [:show, :create]
  layout "public_forms"

  def show
    @submission = Submission.new
  end

  def create
    @submission = @form.submissions.new(submission_params)
    @submission.device = @device

    # Associate the submission with the current user if logged in
    @submission.user = current_user if current_user

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

      # Redirect to thanks page instead of rendering
      # This prevents form resubmission on refresh
      redirect_to form_thanks_path(@form, @device)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def thanks
    # This is rendered after successful form submission
    # No specific submission data needed
  end

  def qr_code
    # Generate QR code for the form-device combination
    url = public_form_url(@form.id, @device.id)
    size = params[:size].present? ? params[:size].to_i : 200

    # Create QR code with appropriate size
    qrcode = RQRCode::QRCode.new(url)

    # Generate PNG image
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: size / qrcode.modules.size,
      resize_exactly_to: false,
      resize_gte_to: false
    )

    # Send the PNG image as a response
    send_data png.to_s, type: 'image/png', disposition: 'inline'
  end

  private

  def set_form_and_device
    @form = Form.find(params[:form_id])
    @device = Device.find(params[:device_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Form or device not found"
  end

  def set_form_and_device_for_qr
    # Similar to set_form_and_device but renders PNG instead of redirecting
    @form = Form.find(params[:form_id])
    @device = Device.find(params[:device_id])
  rescue ActiveRecord::RecordNotFound
    # Return a default 'not found' QR code or error image
    blank_qr = ChunkyPNG::Image.new(200, 200, ChunkyPNG::Color::WHITE)
    send_data blank_qr.to_s, type: 'image/png', disposition: 'inline'
  end

  def check_form_access
    # Redirect to login if the form requires login and user is not logged in
    if @form.require_login && !logged_in?
      store_location # Store the current URL to redirect back after login
      redirect_to login_path, alert: "You need to log in to access this form"
    end
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
