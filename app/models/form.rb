class Form < ApplicationRecord
  has_one_attached :header_image
  has_one_attached :intro_image
  has_one_attached :thank_you_image
  has_many :submissions, dependent: :destroy
  has_and_belongs_to_many :devices
  has_many :codes, dependent: :destroy

  validates :name, presence: true
  validates :button_text, presence: true
  validates :target_email_address, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true
  validates :token_validity_seconds, numericality: {greater_than_or_equal_to: 1, only_integer: true}

  # Default colors if none provided
  before_validation :set_default_colors

  private

  def set_default_colors
    self.background_color ||= "#ffffff"
    self.text_color ||= "#333333"
    self.button_color ||= "#4CAF50"
    self.button_text_color ||= "#ffffff"
    self.start_over_button_text ||= "Start Over"
    self.intro_image_hover_outline_color ||= "#4CAF50"
  end
end
