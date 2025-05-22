class Device < ApplicationRecord
  self.primary_key = :id
  before_validation :generate_id, on: :create

  has_many :submissions, dependent: :destroy
  has_and_belongs_to_many :forms

  validates :id, presence: true, uniqueness: true, length: {is: 12}
  validates :name, presence: true

  # Claims the free credit if available and returns true
  # Returns false if no free credit is available
  def claim_free_credit
    return false unless free_credit

    transaction do
      update!(free_credit: false)
      return true
    end
  end

  # Update the last_heard_from timestamp to current time
  def update_last_heard_from
    update(last_heard_from: Time.current)
  end

  private

  def generate_id
    self.id ||= SecureRandom.alphanumeric(12)
  end
end
