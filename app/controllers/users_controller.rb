class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :require_admin, only: [:index, :edit, :update, :destroy, :impersonate]
  before_action :set_user, only: [:edit, :update, :destroy, :change_password, :update_password, :impersonate]
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
<<<<<<< HEAD
    @user = User.new(user_params)
    if @user.save
      if Rails.env.production?
        NtfyService.notify("new user: #{@user.email}")
=======
    # Only allow user creation if:
    # 1. There are no users yet (first user becomes admin via callback in User model)
    # 2. The current user is an admin
    if User.count == 0 || current_user&.admin?
      @user = User.new(user_params)
      if @user.save
        if Rails.env.production?
          NtfyService.notify("new user: #{@user.email}")
        end

        # Auto-login the user if this is the first user
        if User.count == 1
          log_in @user
        end

        flash[:success] = "Account created"
        redirect_to current_user&.admin? ? users_path : root_path
      else
        render :new, status: :unprocessable_entity
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
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

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    if current_user&.admin?
      # Admins can set email, admin status, and password
      params.require(:user).permit(
        :email,
        :password,
        :password_confirmation,
        :admin
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
