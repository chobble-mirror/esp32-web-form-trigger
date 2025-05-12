class Form < ApplicationRecord
  has_one_attached :header_image
  has_many :submissions, dependent: :destroy

  validates :name, presence: true
  validates :button_text, presence: true
  validates :header_text, presence: true
  validates :target_email_address, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}

  # Default colors if none provided
  before_validation :set_default_colors

  private

  def set_default_colors
    self.background_color ||= "#ffffff"
    self.text_color ||= "#333333"
    self.button_color ||= "#4CAF50"
    self.button_text_color ||= "#ffffff"
  end
end
