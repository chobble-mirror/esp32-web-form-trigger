require "csv"
require "zip"
require "tempfile"
require "rqrcode"

class CodesController < ApplicationController
  before_action :require_login
  before_action :set_code, only: %i[destroy]

  def index
    @codes = Code.all.includes(:device, :form)
    @devices = Device.all
    @forms = Form.all

    # Count for all codes
    @total_count = @codes.count

    # Get counts by device and form
    @device_counts = @codes.group(:device_id).count
    @form_counts = @codes.group(:form_id).count

    # Filter by claimed status
    if params[:filter] == "unclaimed"
      @codes = @codes.unclaimed
    end

    # Filter by device
    if params[:device_id].present?
      @codes = @codes.where(device_id: params[:device_id])
    end

    # Filter by form
    if params[:form_id].present?
      @codes = @codes.where(form_id: params[:form_id])
    end

    @codes = @codes.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv, filename: generate_export_filename("csv")
      end
      format.zip do
        send_data generate_qr_code_zip, filename: generate_export_filename("zip")
      end
    end
  end

  def new
    @code = Code.new
    @devices = Device.all
    @forms = Form.all
  end

  def create
    count = params[:count].to_i
    count = 1 if count < 1 || count > 10000

    device = Device.find_by(id: params[:code][:device_id])
    form = Form.find_by(id: params[:code][:form_id])

    if !device || !form
      error_message = []
      error_message << "Device not found" if !device
      error_message << "Form not found" if !form
      flash[:error] = "Error creating codes: #{error_message.join(", ")}"
      redirect_to new_code_path
      return
    end

    created_codes = []

    ActiveRecord::Base.transaction do
      count.times do
        # Create the code directly with device and form objects instead of using code_params
        code = Code.new(device: device, form: form)
        if code.save
          created_codes << code
        else
          flash[:error] = "Error creating codes: #{code.errors.full_messages.join(", ")}"
          redirect_to new_code_path
          return
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to codes_path, notice: "Successfully created #{created_codes.size} code(s)." }
    end
  end

  def destroy
    @code.destroy
    respond_to do |format|
      format.html { redirect_to codes_path, notice: "Code was successfully deleted." }
    end
  end

  private

  def set_code
    @code = Code.find(params[:id])
  end

  def code_params
    params.require(:code).permit(:device_id, :form_id)
  end

  def generate_export_filename(extension)
    # Create a descriptive filename based on filters
    if params[:form_id].present? && params[:device_id].present?
      form_name = Form.find(params[:form_id]).name
      device_name = Device.find(params[:device_id]).name
      count = @codes.count
      "#{form_name} (#{device_name}) x#{count}.#{extension}"
    elsif params[:form_id].present?
      form_name = Form.find(params[:form_id]).name
      count = @codes.count
      "#{form_name} (all devices) x#{count}.#{extension}"
    elsif params[:device_id].present?
      device_name = Device.find(params[:device_id]).name
      count = @codes.count
      "All forms (#{device_name}) x#{count}.#{extension}"
    else
      count = @codes.count
      "All codes x#{count}.#{extension}"
    end
  end

  def generate_qr_code_zip
    temp_file = Tempfile.new(["qr_codes", ".zip"])
    begin
      # Create a zip file
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
        @codes.each do |code|
          # Generate QR code using the model method
          png = code.qr_code(self, 6) # Size 6 creates a ~300px QR code

          # Add the QR code to the zip file with the code ID as the filename
          zipfile.get_output_stream("#{code.id}.png") { |f| f.write(png.to_s) }
        end
      end

      # Read the zip file data for sending
      File.binread(temp_file.path)
    ensure
      # Clean up the temp file
      temp_file.close
      temp_file.unlink
    end
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      # Build headers
      headers = ["Code", "Device Name", "Form Name", "Status", "Created At", "URL", "QR Code URL"]
      csv << headers

      # Add data
      @codes.each do |code|
        status = code.claimed? ? "Claimed (#{code.claimed_at.strftime("%Y-%m-%d %H:%M")})" : "Unclaimed"
        url = public_code_url(code.id)
        qr_url = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=#{CGI.escape(url)}"

        row = [
          code.id,
          code.device.name,
          code.form.name,
          status,
          code.created_at.strftime("%Y-%m-%d %H:%M"),
          url,
          qr_url
        ]

        csv << row
      end
    end
  end
end
