class LinksController < ApplicationController
  before_action :require_login
  
  def index
    @devices = Device.where(archived: false).order(:name)
    @forms = Form.order(:name)
  end
end