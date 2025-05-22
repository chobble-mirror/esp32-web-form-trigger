class Form < ApplicationRecord
  before_validation :generate_code, on: :create

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
  validates :code, uniqueness: true, length: {is: 12}, allow_nil: true

  # Default colors if none provided
  before_validation :set_default_colors

  # Find by code or ID
  def self.find_by_code_or_id(code_or_id)
    find_by(code: code_or_id) || find_by(id: code_or_id)
  end

  private

  def generate_code
    self.code ||= SecureRandom.alphanumeric(12).upcase
  end

  def set_default_colors
    self.background_color ||= "#f8f9fa"
    self.text_color ||= "#212529"
    self.button_color ||= "#0d6efd"
    self.button_text_color ||= "#ffffff"
    self.start_over_button_text ||= "Start Over"
    self.intro_image_hover_outline_color ||= "#0d6efd"
  end
end
