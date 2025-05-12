module AuthHelpers
  def login_as_admin
    # Make sure to clear users first to avoid issues with first user being admin
    User.destroy_all

    admin = User.create!(
      email: "admin_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: true
    )
    post login_path, params: {session: {email: admin.email, password: "password123"}}
    expect(session[:user_id]).to eq(admin.id)
    admin
  end

  def login_as_user
    # Create admin first
    User.create!(
      email: "admin_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: true
    )

    # Then create regular user
    user = User.create!(
      email: "user_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )
    post login_path, params: {session: {email: user.email, password: "password123"}}
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
