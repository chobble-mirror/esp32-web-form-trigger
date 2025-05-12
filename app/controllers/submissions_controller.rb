require "csv"

class SubmissionsController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_submission, only: [:show]

  def index
    @forms = Form.all.includes(:submissions)
    @form_counts = Form.joins(:submissions)
      .group("forms.id")
      .count("submissions.id")
    @total_count = Submission.count

    # Apply form filter if specified
    base_query = Submission.includes(:form, :device)
    if params[:form_id].present?
      @form = Form.find(params[:form_id])
      @submissions = base_query.where(form_id: params[:form_id]).order(created_at: :desc)
    else
      @submissions = base_query.order(created_at: :desc)
    end

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
        "Date", "Form", "Device", "Name", "Email",
        "Phone", "Address", "Postcode", "Credit Status", "Email Status"
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
