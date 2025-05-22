module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def remember_user
    cookies.permanent.signed[:user_id] = current_user.id if current_user
  end

  def forget_user
    cookies.delete(:user_id)
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    forget_user
    @current_user = nil
  end

  # Store the URL trying to be accessed
  def store_location
    # Check for both GET and HEAD requests (Rails treats HEAD as GET)
    session[:forwarding_url] = request.original_url if request.get? || request.head?
  end

  # Redirects to stored location (or to the default)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end
