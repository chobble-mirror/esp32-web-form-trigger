require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(
        email: "test@example.com",
        password: "password",
        password_confirmation: "password"
      )
      expect(user).to be_valid
    end

    it "requires an email" do
      user = User.new(password: "password", password_confirmation: "password")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "requires a valid email format" do
      user = User.new(
        email: "invalid-email",
        password: "password",
        password_confirmation: "password"
      )
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it "requires a password" do
      user = User.new(email: "test@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "requires a password of at least 6 characters" do
      user = User.new(
        email: "test@example.com",
        password: "short",
        password_confirmation: "short"
      )
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "requires a unique email" do
      # Create a user with a specific email
      User.create!(
        email: "duplicate@example.com",
        password: "password",
        password_confirmation: "password"
      )

      # Try to create another user with the same email
      duplicate_user = User.new(
        email: "duplicate@example.com",
        password: "password",
        password_confirmation: "password"
      )

      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("has already been taken")
    end
  end

  describe "admin functionality" do
    it "sets the first user as admin" do
      # Make sure there are no users
      User.destroy_all

      # Create the first user
      first_user = User.create!(
        email: "admin@example.com",
        password: "password",
        password_confirmation: "password"
      )

      # Create a second user
      second_user = User.create!(
        email: "regular@example.com",
        password: "password",
        password_confirmation: "password"
      )

      # Verify the first user is an admin
      expect(first_user.admin?).to be true

      # Verify the second user is not an admin
      expect(second_user.admin?).to be false
    end
  end
end
