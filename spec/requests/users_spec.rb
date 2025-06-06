require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "returns http success" do
      get "/signup"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /signup" do
    context "when there are no users yet" do
      before do
        User.destroy_all
      end

      it "creates a user and redirects" do
        post "/signup", params: {
          user: {
            email: "newuser@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }

        expect(response).to have_http_status(:redirect)
        expect(User.count).to eq(1)
        expect(User.first.admin).to be true
      end
    end
    context "when logged in as admin" do
      before do
        login_as_admin
      end

      it "prevents even admin from creating a user while logged in" do
        post "/signup", params: {
          user: {
            email: "newuser@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to eq("Already logged in")
        expect(User.find_by(email: "newuser@example.com")).to be_nil
      end
    end

    context "when logged in as regular user" do
      before do
        login_as_user
      end

      it "prevents creating a new user when already logged in" do
        post "/signup", params: {
          user: {
            email: "newuser2@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to eq("Already logged in")
        expect(User.find_by(email: "newuser2@example.com")).to be_nil
      end
    end
  end

  # User permission tests related to admin access have been moved to admin_permissions_spec.rb

  describe "password change functionality" do
    let(:user) { User.create!(email: "user@example.com", password: "password", password_confirmation: "password") }
    let(:admin) { User.create!(email: "admin@example.com", password: "password", password_confirmation: "password", admin: true) }

    context "when logged in as the user" do
      before do
        post "/login", params: {session: {email: user.email, password: "password"}}
      end

      it "allows access to change password page" do
        get change_password_user_path(user)
        expect(response).to have_http_status(200)
      end

      it "updates the user's password when current password is correct" do
        patch update_password_user_path(user), params: {
          user: {
            current_password: "password",
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }

        expect(response).to redirect_to(root_path)

        # Verify password was changed
        user.reload
        expect(user.authenticate("newpassword")).to be_truthy
      end

      it "does not update the password when current password is incorrect" do
        patch update_password_user_path(user), params: {
          user: {
            current_password: "wrongpassword",
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)

        # Verify password was not changed
        user.reload
        expect(user.authenticate("password")).to be_truthy
      end

      it "does not allow changing another user's password" do
        other_user = User.create!(email: "other@example.com", password: "password", password_confirmation: "password")

        get change_password_user_path(other_user)
        expect(response).to redirect_to(root_path)

        patch update_password_user_path(other_user), params: {
          user: {
            current_password: "password",
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }

        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to be_present
      end
    end

    context "when not logged in" do
      it "redirects to login page" do
        get change_password_user_path(user)
        expect(response).to redirect_to(login_path)

        patch update_password_user_path(user), params: {
          user: {
            current_password: "password",
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
