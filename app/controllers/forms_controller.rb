class FormsController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_form, only: [:edit, :update, :destroy]

  def index
    @forms = Form.all
  end

  def new
    @form = Form.new
  end

  def edit
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
      redirect_to forms_path, notice: "Form was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @form.destroy
    redirect_to forms_path, notice: "Form was successfully deleted."
  end

  private
    def set_form
      @form = Form.find(params[:id])
    end

    def form_params
      params.require(:form).permit(
        :name,
        :header_image, 
        :background_color, 
        :text_color, 
        :button_color, 
        :button_text_color, 
        :button_text, 
        :header_text, 
        :enable_name, 
        :enable_email_address, 
        :enable_phone, 
        :enable_address, 
        :enable_postcode, 
        :terms_and_conditions, 
        :thank_you_text, 
        :target_email_address
      )
    end
end