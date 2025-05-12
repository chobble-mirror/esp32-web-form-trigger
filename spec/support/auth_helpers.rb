module AuthHelpers
  def login_as_admin
<<<<<<< HEAD
    # Create admin user if it doesn't exist
    admin = User.find_by(email: "stefan@chobble.com")

    admin ||= User.create!(
      email: "stefan@chobble.com",
      password: "password",
      password_confirmation: "password",
      admin: true
    )

    post login_path, params: {session: {email: admin.email, password: "password"}}
=======
    # Make sure to clear users first to avoid issues with first user being admin
    User.destroy_all

    admin = User.create!(
      email: "admin_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: true
    )
    post login_path, params: {session: {email: admin.email, password: "password123"}}
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
    expect(session[:user_id]).to eq(admin.id)
    admin
  end

  def login_as_user
<<<<<<< HEAD
    # Make sure admin exists
    admin = User.find_by(email: "stefan@chobble.com")

    unless admin
      User.create!(
        email: "stefan@chobble.com",
        password: "password",
        password_confirmation: "password",
        admin: true
      )
    end

    # Create regular user
=======
    # Create admin first
    User.create!(
      email: "admin_#{Time.now.to_i}@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: true
    )

    # Then create regular user
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
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
