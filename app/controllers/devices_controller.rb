class DevicesController < ApplicationController
  before_action :set_device, only: [:edit, :update, :archive, :unarchive, :show, :reset_credit]
  before_action :require_admin, except: [:show, :reset_credit]
  layout "public_device", only: [:show]

  def index
    @filter = params[:filter] || "active"
    @total_count = Device.count
    @archived_count = Device.where(archived: true).count

    @devices = if @filter == "all"
      Device.all.order(created_at: :desc)
    elsif @filter == "archived"
      Device.where(archived: true).order(created_at: :desc)
    else
      Device.where(archived: false).order(created_at: :desc)
    end

    # Preload the last submission for each device to avoid N+1 queries
    @last_submissions = {}
    device_ids = @devices.pluck(:id)

    # Get the most recent submission for each device using a direct query to get the actual submission objects
    device_ids.each do |device_id|
      last_submission = Submission.where(device_id: device_id).order(created_at: :desc).first
      @last_submissions[device_id] = last_submission.created_at if last_submission
    end
  end

  def new
    @device = Device.new
  end

  def create
    @device = Device.new(device_params)

    if @device.save
      redirect_to edit_device_path(@device), notice: "Device was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @device.update(device_params)
      redirect_to edit_device_path(@device), notice: "Device was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @device.update(archived: true)
    redirect_to devices_path, notice: "Device was successfully archived.", status: :see_other
  end

  def unarchive
    @device.update(archived: false)
    redirect_to devices_path, notice: "Device was successfully restored.", status: :see_other
  end

  # Public device page showing stats
  def show
    @forms = Form.joins(:submissions)
      .where(submissions: {device_id: @device.id})
      .distinct
      .order(name: :asc)

    @total_submissions = @device.submissions.count
    @last_submission = @device.submissions.order(created_at: :desc).first
  end

  # Reset free credit for a device
  def reset_credit
    @device.update(free_credit: true)

    # Load the same data as in the show action to avoid nil errors
    @forms = Form.joins(:submissions)
      .where(submissions: {device_id: @device.id})
      .distinct
      .order(name: :asc)

    @total_submissions = @device.submissions.count
    @last_submission = @device.submissions.order(created_at: :desc).first

    redirect_to public_device_path(@device), notice: "Free credit reset successfully."
  end

  private

  def set_device
    @device = Device.find(params[:id])
  end

  def device_params
    params.require(:device).permit(:name, :location, :always_allow_credit_claim)
  end
end
