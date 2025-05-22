class User < ApplicationRecord
  has_secure_password
  has_many :submissions

  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true, length: {minimum: 6}, if: :password_digest_changed?

  before_validation :downcase_email
  before_create :make_first_user_admin

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def make_first_user_admin
    # If this is the first user, make them an admin
    self.admin = true if User.count.zero?
  end
end
