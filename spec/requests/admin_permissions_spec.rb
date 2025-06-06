require "rails_helper"

RSpec.describe "Admin Permissions", type: :request do
  describe "Resource access restrictions" do
    let!(:device) { Device.create!(name: "Test Device", location: "Test Location") }
    let!(:form) do
      Form.create!(
        name: "Test Form",
        background_color: "#ffffff",
        text_color: "#000000",
        button_color: "#0000ff",
        button_text_color: "#ffffff",
        button_text: "Submit",
        header_text: "Test form",
        target_email_address: "test@example.com"
      )
    end
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
        # Create user and admin to ensure we have both roles
        User.destroy_all

        User.create!(
          email: "admin@example.com",
          password: "password123",
          password_confirmation: "password123",
          admin: true
        )

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
        post toggle_admin_user_path(@user)
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
        # Start fresh
        User.destroy_all

        @admin = User.create!(
          email: "admin@example.com",
          password: "password123",
          password_confirmation: "password123",
          admin: true
        )

        post login_path, params: {session: {email: @admin.email, password: "password123"}}
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

        post toggle_admin_user_path(user)
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
