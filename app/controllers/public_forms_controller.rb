class PublicFormsController < ApplicationController
  require "rqrcode"
  include SubmissionProcessing

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
    process_submission
  end

  def thanks
    # This is rendered after successful form submission
    # No specific submission data needed
  end

  def qr_code
    # Generate QR code for the form-device combination
    url = public_form_url(@form.code, @device.id)
    size = params[:size].present? ? params[:size].to_i : 200

    # Create QR code with appropriate size
    qrcode = RQRCode::QRCode.new(url)

    # Generate PNG image
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: size / qrcode.modules.size,
      resize_exactly_to: false,
      resize_gte_to: false
    )

    # Send the PNG image as a response
    send_data png.to_s, type: "image/png", disposition: "inline"
  end

  private

  def set_form_and_device
    @form = Form.find_by(code: params[:code])
    @device = Device.find(params[:device_id])
    raise ActiveRecord::RecordNotFound unless @form && @device
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Form or device not found"
  end

  def set_form_and_device_for_qr
    # Similar to set_form_and_device but renders PNG instead of redirecting
    @form = Form.find_by(code: params[:code])
    @device = Device.find(params[:device_id])
    raise ActiveRecord::RecordNotFound unless @form && @device
  rescue ActiveRecord::RecordNotFound
    # Return a default 'not found' QR code or error image
    blank_qr = ChunkyPNG::Image.new(200, 200, ChunkyPNG::Color::WHITE)
    send_data blank_qr.to_s, type: "image/png", disposition: "inline"
  end
end
