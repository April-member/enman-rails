# frozen_string_literal: true

class Tenant < ApplicationRecord
  encrypts :invitation_token, deterministic: true

  has_many :users, dependent: :destroy

  validates :name, presence: true

  before_create :generate_invitation_token

  private

  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64(32)
  end
end
