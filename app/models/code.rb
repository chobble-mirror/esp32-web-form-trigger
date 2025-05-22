class Code < ApplicationRecord
  require "rqrcode"

  self.primary_key = :id
  before_validation :generate_id, on: :create

  belongs_to :device
  belongs_to :form

  validates :id, presence: true, uniqueness: true, length: {is: 12}

  scope :unclaimed, -> { where(claimed_at: nil) }

  def claim!
    update!(claimed_at: Time.current)
  end

  def claimed?
    claimed_at.present?
  end

  def public_url(view_context)
    view_context.public_code_url(id)
  end

  def qr_code(view_context, size = 6)
    # Generate QR code for the code's public URL
    url = public_url(view_context)
    qrcode = RQRCode::QRCode.new(url)

    # Generate PNG image
    qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: size, # Adjust size as needed
      resize_exactly_to: false,
      resize_gte_to: false
    )
  end

  private

  def generate_id
    self.id ||= SecureRandom.alphanumeric(12).upcase
  end
end
