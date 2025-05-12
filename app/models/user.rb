class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true, length: {minimum: 6}, if: :password_digest_changed?
  
  before_create :make_first_user_admin
  
  private
  
  def make_first_user_admin
    # If this is the first user, make them an admin
    self.admin = true if User.count.zero?
  end
end
