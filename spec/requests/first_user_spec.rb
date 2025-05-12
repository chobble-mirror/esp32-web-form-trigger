require "rails_helper"

RSpec.describe "User Signup", type: :request do
  before do
    # Ensure we start with a clean slate
    User.destroy_all
  end

  it "allows the first user to sign up" do
    expect(User.count).to eq(0)

    post signup_path, params: {
      user: {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    expect(response).to have_http_status(:redirect)
    expect(User.count).to eq(1)
    new_user = User.find_by(email: "newuser@example.com")
    expect(new_user).to be_present
    expect(new_user.admin).to be true
  end

  it "sets the first user as admin automatically" do
    post signup_path, params: {
      user: {
        email: "newuser2@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

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

    it "allows anyone to create additional user accounts" do
      # Try to create a second user without being an admin
      post signup_path, params: {
        user: {
          email: "second@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      expect(User.count).to eq(2)
      expect(User.find_by(email: "second@example.com")).to be_present
      expect(User.find_by(email: "second@example.com").admin).to be false
    end

    it "prevents logged-in users from accessing signup page" do
      # Login as admin
      admin = User.first
      post login_path, params: {session: {email: admin.email, password: "password123"}}

      # Try to create a second user while logged in
      post signup_path, params: {
        user: {
          email: "second@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      # Should be prevented
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path) 
      expect(flash[:danger]).to eq("Already logged in")
      expect(User.count).to eq(1)
      expect(User.find_by(email: "second@example.com")).to be_nil
    end
  end
end
