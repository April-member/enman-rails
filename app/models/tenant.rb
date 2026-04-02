class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy

  encrypts :invitation_token, deterministic: true

  validates :name, presence: true, length: { maximum: 50 }

  # テナントと管理者ユーザーをトランザクション内で一括作成する
  def self.signup!(params)
    transaction do
      tenant = create!(
        name:             params[:tenant_name],
        invitation_token: SecureRandom.urlsafe_base64(24)
      )
      user = tenant.users.create!(
        name:                  params[:user_name],
        email:                 params[:email],
        password:              params[:password],
        password_confirmation: params[:password_confirmation],
        role:                  "admin"
      )
      [ tenant, user ]
    end
  end
end
