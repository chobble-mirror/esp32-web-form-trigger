require "csv"

class SubmissionsController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_submission, only: [:show, :reset_credit]

  def index
    @forms = Form.all.includes(:submissions)
    @form_counts = Form.joins(:submissions)
      .group("forms.id")
      .count("submissions.id")
    @total_count = Submission.count

    # Apply form filter if specified
    base_query = Submission.includes(:form, :device, :user)
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

    # Handle email preview requests
    if params[:preview_email]
      @form = @submission.form
      @device = @submission.device

      # Render the email preview if requested
      render template: "submission_mailer/new_submission", layout: "mailer"
    end
  end

  def reset_credit
    if @submission.credit_claimed
      @submission.reset_credit!
      redirect_to submission_path(@submission), notice: "Credit has been reset and is now available"
    else
      redirect_to submission_path(@submission), alert: "Credit is already available"
    end
  end

  private

  def set_submission
    @submission = Submission.includes(:form, :device, :user).find(params[:id])
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      # Determine which fields have data
      has_user = @submissions.any? { |s| s.user.present? }
      has_name = @submissions.any? { |s| s.name.present? }
      has_email = @submissions.any? { |s| s.email_address.present? }
      has_phone = @submissions.any? { |s| s.phone.present? }
      has_address = @submissions.any? { |s| s.address.present? }
      has_postcode = @submissions.any? { |s| s.postcode.present? }

      # Build headers dynamically
      headers = ["Date", "Form", "Device"]
      headers << "Logged In User" if has_user
      headers << "Name" if has_name
      headers << "Email" if has_email
      headers << "Phone" if has_phone
      headers << "Address" if has_address
      headers << "Postcode" if has_postcode
      headers.concat(["Credit Status", "Email Status"])

      # Add headers
      csv << headers

      # Add data
      @submissions.each do |submission|
        row = [
          submission.created_at.strftime("%Y-%m-%d %H:%M"),
          submission.form.name,
          submission.device.name
        ]

        row << submission.user&.email if has_user
        row << submission.name if has_name
        row << submission.email_address if has_email
        row << submission.phone if has_phone
        row << submission.address if has_address
        row << submission.postcode if has_postcode

        row.concat([
          submission.credit_claimed ? "Claimed" : "Available",
          submission.email_status
        ])

        csv << row
      end
    end
  end
end
