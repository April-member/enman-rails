# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :tenant

  has_secure_password

  enum :role, { admin: 0, member: 1 }

  validates :name, presence: true
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
