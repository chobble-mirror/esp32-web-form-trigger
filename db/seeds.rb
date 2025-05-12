# Create admin user
unless User.exists?(email: "stefan@chobble.com")
  User.create!(
    email: "stefan@chobble.com",
    password: "password",
    password_confirmation: "password",
    admin: true
  )
end
