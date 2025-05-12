require "rails_helper"

RSpec.describe "Admin Permissions", type: :request do
  describe "Resource access restrictions" do
    let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
<<<<<<< HEAD
    let!(:form) { create_test_form }
=======
    let!(:form) do
      Form.create!(
        background_color: "#ffffff",
        text_color: "#000000",
        button_color: "#0000ff",
        button_text_color: "#ffffff",
        button_text: "Submit",
        header_text: "Test form",
        target_email_address: "test@example.com"
      )
    end
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
    let!(:submission) do
      Submission.create!(
        device: device,
        form: form,
        name: "Test User",
        email_address: "test@example.com"
      )
    end

    context "when not logged in" do
      it "redirects all admin resources to login" do
        # Devices
        get devices_path
        expect(response).to redirect_to(login_path)

        # Forms
        get forms_path
        expect(response).to redirect_to(login_path)

        # Submissions
        get submissions_path
        expect(response).to redirect_to(login_path)

        # Users
        get users_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as regular user" do
      before do
<<<<<<< HEAD
        # Create admin user if it doesn't exist
        admin = User.find_by(email: "stefan@chobble.com")

        unless admin
          User.create!(
            email: "stefan@chobble.com",
            password: "password",
            password_confirmation: "password",
            admin: true
          )
        end
=======
        # Create user and admin to ensure we have both roles
        User.destroy_all

        User.create!(
          email: "admin@example.com",
          password: "password123",
          password_confirmation: "password123",
          admin: true
        )
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea

        @user = User.create!(
          email: "user@example.com",
          password: "password123",
          password_confirmation: "password123",
          admin: false
        )

        post login_path, params: {session: {email: @user.email, password: "password123"}}
      end

      it "redirects all admin resources to root" do
        # Devices
        get devices_path
        expect(response).to redirect_to(root_path)

        # Forms
        get forms_path
        expect(response).to redirect_to(root_path)

        # Submissions
        get submissions_path
        expect(response).to redirect_to(root_path)

        # Users
        get users_path
        expect(response).to redirect_to(root_path)
      end

      it "cannot modify their own admin status" do
        patch user_path(@user), params: {user: {admin: true}}
        @user.reload
        expect(@user.admin).to be false
      end

      it "cannot modify their own email" do
        original_email = @user.email
        patch user_path(@user), params: {user: {email: "changed@example.com"}}
        @user.reload
        expect(@user.email).to eq(original_email)
      end
    end

    context "when logged in as admin" do
      before do
<<<<<<< HEAD
        # Create admin user if it doesn't exist
        @admin = User.find_by(email: "stefan@chobble.com")

        @admin ||= User.create!(
          email: "stefan@chobble.com",
          password: "password",
          password_confirmation: "password",
          admin: true
        )

        post login_path, params: {session: {email: @admin.email, password: "password"}}
=======
        # Start fresh
        User.destroy_all

        @admin = User.create!(
          email: "admin@example.com",
          password: "password123",
          password_confirmation: "password123",
          admin: true
        )

        post login_path, params: {session: {email: @admin.email, password: "password123"}}
>>>>>>> 6fe14cbda0429cfc345fc69a1d9e822d7debefea
      end

      it "can access all admin resources" do
        # Devices
        get devices_path
        expect(response).to have_http_status(:success)

        # Forms
        get forms_path
        expect(response).to have_http_status(:success)

        # Submissions
        get submissions_path
        expect(response).to have_http_status(:success)

        # Users
        get users_path
        expect(response).to have_http_status(:success)
      end

      it "can make another user an admin" do
        user = User.create!(
          email: "user@example.com",
          password: "password123",
          password_confirmation: "password123",
          admin: false
        )

        patch user_path(user), params: {user: {admin: true}}
        user.reload
        expect(user.admin).to be true
      end

      it "can change another user's email" do
        user = User.create!(
          email: "user@example.com",
          password: "password123",
          password_confirmation: "password123"
        )

        patch user_path(user), params: {user: {email: "changed@example.com"}}
        user.reload
        expect(user.email).to eq("changed@example.com")
      end
    end
  end
end
