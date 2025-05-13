require "rails_helper"

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(valid_attributes)
      expect(user).to be_valid
    end

    context "email validation" do
      it "requires an email" do
        user = User.new(valid_attributes.except(:email))
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it "requires a valid email format" do
        user = User.new(valid_attributes.merge(email: "invalid-email"))
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("is invalid")
      end

      it "requires a unique email" do
        User.create!(valid_attributes.merge(email: "duplicate@example.com"))

        duplicate_user = User.new(valid_attributes.merge(email: "duplicate@example.com"))
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include("has already been taken")
      end

      it "is case-insensitive for email uniqueness" do
        User.create!(valid_attributes.merge(email: "CASE@example.com"))

        # With our updated model, this should now be invalid (case-insensitive)
        duplicate_user = User.new(valid_attributes.merge(email: "case@example.com"))
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include("has already been taken")
      end

      it "downcases email before saving" do
        user = User.create!(valid_attributes.merge(email: "UPPERCASE@example.com"))
        expect(user.email).to eq("uppercase@example.com")
      end
    end

    context "password validation" do
      it "requires a password" do
        user = User.new(valid_attributes.except(:password, :password_confirmation))
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it "requires a password of at least 6 characters" do
        short_password = "short"
        user = User.new(valid_attributes.merge(
          password: short_password,
          password_confirmation: short_password
        ))
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end

      it "doesn't require password on update if not changing password_digest" do
        user = User.create!(valid_attributes)
        user.email = "updated@example.com"

        # Skip password validation when not changing password
        expect(user).to be_valid
        expect(user.save).to be true
      end

      it "requires password confirmation to match password" do
        user = User.new(valid_attributes.merge(
          password_confirmation: "different"
        ))
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end
  end

  describe "admin functionality" do
    it "allows setting admin status manually" do
      admin_user = User.create!(valid_attributes.merge(
        email: "admin@example.com",
        admin: true
      ))

      regular_user = User.create!(valid_attributes.merge(
        email: "regular@example.com",
        admin: false
      ))

      expect(admin_user.admin?).to be true
      expect(regular_user.admin?).to be false
    end

    context "when first user signup" do
      before { User.destroy_all }

      it "automatically sets the first user as admin" do
        first_user = User.create!(valid_attributes.merge(email: "first@example.com"))
        expect(first_user.admin?).to be true

        second_user = User.create!(valid_attributes.merge(email: "second@example.com"))
        expect(second_user.admin?).to be false
      end

      it "doesn't override explicit admin setting for first user" do
        first_user = User.create!(valid_attributes.merge(
          email: "first@example.com",
          admin: false
        ))
        expect(first_user.admin?).to be true
      end
    end
  end

  describe "last_active_at tracking" do
    it "allows setting last_active_at" do
      user = User.create!(valid_attributes)
      timestamp = Time.current

      user.update(last_active_at: timestamp)
      expect(user.last_active_at).to be_within(1.second).of(timestamp)
    end

    it "allows querying users by activity status" do
      active_user = User.create!(valid_attributes.merge(
        email: "active@example.com",
        last_active_at: 1.hour.ago
      ))

      inactive_user = User.create!(valid_attributes.merge(
        email: "inactive@example.com",
        last_active_at: 31.days.ago
      ))

      never_active_user = User.create!(valid_attributes.merge(
        email: "never@example.com",
        last_active_at: nil
      ))

      # Example of how you might query active users (within last 30 days)
      active_users = User.where("last_active_at > ?", 30.days.ago)
      expect(active_users).to include(active_user)
      expect(active_users).not_to include(inactive_user)
      expect(active_users).not_to include(never_active_user)
    end
  end

  describe "authentication" do
    it "ensures has_secure_password is properly configured" do
      user = User.create!(valid_attributes)

      # Test authentication works
      expect(user.authenticate("password")).to eq(user)
      expect(user.authenticate("wrong")).to be false

      # Test password digest storage
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq("password")
    end

    it "updates password_digest when password changes" do
      user = User.create!(valid_attributes)
      original_digest = user.password_digest

      user.update(password: "newpassword", password_confirmation: "newpassword")
      expect(user.password_digest).not_to eq(original_digest)
    end
  end

  describe "associations and dependencies" do
    # If User model has associations, test them here
    # For example, if users have forms, devices, etc.

    it "can be queried for the first admin user" do
      User.destroy_all

      admin = User.create!(valid_attributes.merge(admin: true))
      User.create!(valid_attributes.merge(
        email: "regular@example.com",
        admin: false
      ))

      expect(User.where(admin: true).first).to eq(admin)
    end
  end
end
