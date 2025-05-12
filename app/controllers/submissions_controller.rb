require 'csv'

class SubmissionsController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_submission, only: [:show]
  
  def index
    @submissions = Submission.includes(:form, :device).order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.csv do
        send_data generate_csv, filename: "submissions-#{Date.today}.csv"
      end
    end
  end
  
  def show
    # @submission is set by the before_action
  end
  
  private
  
  def set_submission
    @submission = Submission.includes(:form, :device).find(params[:id])
  end
  
  def generate_csv
    CSV.generate(headers: true) do |csv|
      # Add headers
      csv << [
        'Date', 'Form', 'Device', 'Name', 'Email', 
        'Phone', 'Address', 'Postcode', 'Credit Status', 'Email Status'
      ]
      
      # Add data
      @submissions.each do |submission|
        csv << [
          submission.created_at.strftime("%Y-%m-%d %H:%M"),
          submission.form.name,
          submission.device.name,
          submission.name,
          submission.email_address,
          submission.phone,
          submission.address,
          submission.postcode,
          submission.credit_claimed ? "Claimed" : "Available",
          submission.email_status
        ]
      end
    end
  end
end