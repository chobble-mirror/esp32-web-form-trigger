require "rails_helper"

RSpec.describe "User Signup", type: :request do
  before do
    # Ensure we start with a clean slate
    User.destroy_all

    # Create the admin user as would be done in seeds
    User.create!(
      email: "stefan@chobble.com",
      password: "password",
      password_confirmation: "password",
      admin: true
    )
  end

<<<<<<< HEAD
  it "allows an admin to create a user" do
    # Login as admin
    post login_path, params: {session: {email: "stefan@chobble.com", password: "password"}}

    # Create a new user
=======
  it "allows the first user to sign up" do
    expect(User.count).to eq(0)

>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
    post signup_path, params: {
      user: {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    expect(response).to have_http_status(:redirect)
    expect(User.count).to eq(2)
    new_user = User.find_by(email: "newuser@example.com")
    expect(new_user).to be_present
    expect(new_user.admin).to be false
  end

<<<<<<< HEAD
  it "allows regular users to create users" do
    # Create a regular user
    regular_user = User.create!(
      email: "regular@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )

    # Login as regular user
    post login_path, params: {session: {email: regular_user.email, password: "password123"}}

    # Try to create a new user
=======
  it "sets the first user as admin automatically" do
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
    post signup_path, params: {
      user: {
        email: "newuser2@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

<<<<<<< HEAD
    expect(User.find_by(email: "newuser2@example.com")).to be_present
    expect(User.find_by(email: "newuser2@example.com").admin).to be false
  end

  it "allows an admin to set another user as admin" do
    # Login as admin
    post login_path, params: {session: {email: "stefan@chobble.com", password: "password"}}

    # Create a regular user
    regular_user = User.create!(
      email: "regular@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )

    # Update the user to be an admin
    patch user_path(regular_user), params: {user: {admin: true}}

    regular_user.reload
    expect(regular_user.admin).to be true
  end

  it "allows an admin to update a user's email" do
    # Login as admin
    post login_path, params: {session: {email: "stefan@chobble.com", password: "password"}}

    # Create a regular user
    regular_user = User.create!(
      email: "regular@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )

    # Update the user's email
    patch user_path(regular_user), params: {user: {email: "updated@example.com"}}

    regular_user.reload
    expect(regular_user.email).to eq("updated@example.com")
  end

  it "prevents a regular user from updating their email" do
    # Create a regular user
    regular_user = User.create!(
      email: "regular@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )

    # Login as regular user
    post login_path, params: {session: {email: regular_user.email, password: "password123"}}

    # Try to update their own email
    patch user_path(regular_user), params: {user: {email: "newemail@example.com"}}

    regular_user.reload
    expect(regular_user.email).to eq("regular@example.com") # Should not change
  end

  it "allows a regular user to update their password" do
    # Create a regular user
    regular_user = User.create!(
      email: "regular@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: false
    )

    # Login as regular user
    post login_path, params: {session: {email: regular_user.email, password: "password123"}}

    # Update password
    patch update_password_user_path(regular_user), params: {
      user: {
        current_password: "password123",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }

    regular_user.reload
    expect(regular_user.authenticate("newpassword")).to be_truthy
  end
=======
    user = User.first
    expect(user.admin).to be true
  end

  context "after first user exists" do
    before do
      # Create first admin user
      User.create!(
        email: "admin@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    it "requires admin privileges to create additional users" do
      # Try to create a second user without being an admin
      post signup_path, params: {
        user: {
          email: "second@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      expect(User.count).to eq(1)
      expect(User.find_by(email: "second@example.com")).to be_nil
    end

    it "allows admin to create additional users" do
      # Login as admin
      admin = User.first
      post login_path, params: {session: {email: admin.email, password: "password123"}}

      # Create a second user
      post signup_path, params: {
        user: {
          email: "second@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      expect(User.count).to eq(2)
      new_user = User.find_by(email: "second@example.com")
      expect(new_user).to be_present
      expect(new_user.admin).to be false
    end
  end
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
end
