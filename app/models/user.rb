class User < ApplicationRecord
  belongs_to :tenant

  has_secure_password

  validates :name, presence: true, length: { maximum: 25 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[admin member] }
end
