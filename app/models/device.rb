class Device < ApplicationRecord
  self.primary_key = :id
  before_validation :generate_id, on: :create
  
  has_many :submissions, dependent: :destroy
  
  validates :id, presence: true, uniqueness: true, length: { is: 12 }
  validates :name, presence: true
  
  private
  
  def generate_id
    self.id ||= SecureRandom.alphanumeric(12)
  end
end
