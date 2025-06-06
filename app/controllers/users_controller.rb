class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :require_not_logged_in, only: [:new, :create]
  before_action :require_admin, only: [:index, :edit, :update, :destroy, :impersonate, :toggle_admin]
  before_action :set_user, only: [:edit, :update, :destroy, :change_password, :update_password, :impersonate, :toggle_admin]
  before_action :require_correct_user, only: [:change_password, :update_password]
  before_action :restrict_regular_user_update, only: [:update]

  def index
    @users = User.all
    @total_images = ActiveStorage::Attachment.count
    @orphaned_images = ActiveStorage::Blob.left_joins(:attachments).where(active_storage_attachments: {id: nil}).count
    @active_jobs = {
      storage_cleanup: {
        name: "StorageCleanupJob",
        scheduled: StorageCleanupJob.scheduled?,
        last_run: StorageCleanupJob.last_run_at,
        next_run: StorageCleanupJob.next_run_at
      }
    }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if Rails.env.production?
        NtfyService.notify("new user: #{@user.email}")
      end
      log_in @user
      flash[:success] = "Account created"
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    update_params = user_params

    # Prevent admin users from changing their own admin status
    if current_user == @user && current_user.admin?
      update_params = update_params.except(:admin)
    end

    if @user.update(update_params)
      flash[:success] = "User updated"
      redirect_to users_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted"
    redirect_to users_path
  end

  def change_password
  end

  def update_password
    if @user.authenticate(params[:user][:current_password])
      if @user.update(password_params)
        flash[:success] = "Password updated"
        redirect_to root_path
      else
        render :change_password, status: :unprocessable_entity
      end
    else
      @user.errors.add(:current_password, "is incorrect")
      render :change_password, status: :unprocessable_entity
    end
  end

  def impersonate
    log_in @user
    flash[:success] = "You are now impersonating #{@user.email}"
    redirect_to root_path
  end

  def toggle_admin
    # Prevent admins from removing their own admin status
    if current_user == @user
      flash[:danger] = "You cannot change your own admin status"
      redirect_to users_path
      return
    end

    @user.update(admin: !@user.admin?)
    flash[:success] = @user.admin? ? "#{@user.email} is now an admin" : "#{@user.email} is no longer an admin"
    redirect_to users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    if current_user&.admin?
      # Admins can set email and password (but not admin status through mass assignment)
      params.require(:user).permit(
        :email,
        :password,
        :password_confirmation
      )
    elsif action_name == "create"
      # For new user registration, allow email and password
      params.require(:user).permit(
        :email,
        :password,
        :password_confirmation
      )
    else
      # Regular users can only update their password
      params.require(:user).permit(:password, :password_confirmation)
    end
  end

  # Using require_admin from ApplicationController

  def require_correct_user
    unless current_user == @user
      flash[:danger] = "You can only change your own password"
      redirect_to root_path
    end
  end

  def require_not_logged_in
    if current_user
      flash[:danger] = "Already logged in"
      redirect_to root_path
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def restrict_regular_user_update
    # Regular users can't update users at all (handled by require_admin)
    # This is just an extra safety measure
    return if current_user&.admin?

    # If somehow a non-admin tries to update users, we should block it
    flash[:danger] = "You do not have permission to modify user information"
    redirect_to root_path
  end
end
