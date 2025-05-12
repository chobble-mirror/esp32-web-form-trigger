# Create admin user
User.create!(
  email: "stefan@chobble.com",
  password: "password",
  password_confirmation: "password",
  admin: true
) unless User.exists?(email: "stefan@chobble.com")