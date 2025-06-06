class FormsController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_form, only: [:edit, :update, :destroy, :remove_image]

  def index
    @forms = Form.all
  end

  def new
    @form = Form.new
  end

  def edit
    @submissions = @form.submissions.order(created_at: :desc).limit(5)
  end

  def create
    @form = Form.new(form_params)

    if @form.save
      redirect_to forms_path, notice: "Form was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @form.update(form_params)
      redirect_to edit_form_path(@form), notice: "Form was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @form.destroy
    redirect_to forms_path, notice: "Form was successfully deleted."
  end

  def remove_image
    image_type = params[:image_type]

    if image_type == "header_image" && @form.header_image.attached?
      @form.header_image.purge
      notice = "Header image was successfully removed."
    elsif image_type == "intro_image" && @form.intro_image.attached?
      @form.intro_image.purge
      notice = "Intro image was successfully removed."
    elsif image_type == "thank_you_image" && @form.thank_you_image.attached?
      @form.thank_you_image.purge
      notice = "Thank you image was successfully removed."
    else
      notice = "No image was found to remove."
    end

    redirect_to edit_form_path(@form), notice: notice
  end

  private

  def set_form
    @form = Form.find_by_code_or_id(params[:id])
    raise ActiveRecord::RecordNotFound unless @form
  end

  def form_params
    params.require(:form).permit(
      :name,
      :header_image,
      :intro_image,
      :thank_you_image,
      :background_color,
      :text_color,
      :button_color,
      :button_text_color,
      :button_text,
      :start_over_button_text,
      :intro_image_hover_outline_color,
      :header_text,
      :enable_name,
      :enable_email_address,
      :enable_phone,
      :enable_address,
      :enable_postcode,
      :terms_and_conditions,
      :thank_you_text,
      :target_email_address,
      :custom_css,
      :require_login,
      :token_validity_seconds,
      :name_field_label,
      :name_field_placeholder,
      :email_field_label,
      :email_field_placeholder,
      :phone_field_label,
      :phone_field_placeholder,
      :address_field_label,
      :address_field_placeholder,
      :postcode_field_label,
      :postcode_field_placeholder
    )
  end
end
