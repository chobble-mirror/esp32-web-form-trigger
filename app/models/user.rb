class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true, length: {minimum: 6}, if: :password_digest_changed?

  before_create :set_admin_if_first_user

  private

  def set_admin_if_first_user
    self.admin = User.count.zero?
  end
end
