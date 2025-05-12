class DevicesController < ApplicationController
  before_action :set_device, only: [:edit, :update, :archive, :unarchive]
  before_action :require_admin

  def index
    @filter = params[:filter] || 'active'
    @total_count = Device.count
    @archived_count = Device.where(archived: true).count
    
    if @filter == 'all'
      @devices = Device.all.order(created_at: :desc)
    elsif @filter == 'archived'
      @devices = Device.where(archived: true).order(created_at: :desc)
    else
      @devices = Device.where(archived: false).order(created_at: :desc)
    end
  end

  def new
    @device = Device.new
  end

  def create
    @device = Device.new(device_params)

    if @device.save
      redirect_to @device, notice: 'Device was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @device.update(device_params)
      redirect_to @device, notice: 'Device was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @device.update(archived: true)
    redirect_to devices_path, notice: 'Device was successfully archived.', status: :see_other
  end
  
  def unarchive
    @device.update(archived: false)
    redirect_to devices_path, notice: 'Device was successfully restored.', status: :see_other
  end

  private

  def set_device
    @device = Device.find(params[:id])
  end

  def device_params
    params.require(:device).permit(:name, :location)
  end
end
