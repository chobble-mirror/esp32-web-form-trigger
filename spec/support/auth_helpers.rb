module AuthHelpers
  def login_as_admin
    # Create admin user if it doesn't exist
    admin = User.find_by(email: "stefan@chobble.com")
    
    unless admin
      admin = User.create!(
        email: "stefan@chobble.com",
        password: "password",
        password_confirmation: "password",
        admin: true
      )
    end
    
    post login_path, params: { session: { email: admin.email, password: "password" } }
    expect(session[:user_id]).to eq(admin.id)
    admin
  end

  def login_as_user
    # Make sure admin exists
    admin = User.find_by(email: "stefan@chobble.com")
    
    unless admin
      admin = User.create!(
        email: "stefan@chobble.com",
        password: "password",
        password_confirmation: "password",
        admin: true
      )
    end
    
    # Create regular user
    user = User.create!(
      email: "user_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )
    post login_path, params: { session: { email: user.email, password: "password123" } }
    expect(session[:user_id]).to eq(user.id)
    user
  end

  def create_admin
    User.create!(
      email: "admin_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: true
    )
  end

  def create_user
    User.create!(
      email: "user_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )
  end
end