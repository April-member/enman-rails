class User < ApplicationRecord
  belongs_to :tenant

  has_secure_password

  validates :name, presence: true, length: { maximum: 25 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[admin member] }

  # JWT アクセストークンを発行する（有効期限: 1時間）
  def generate_jwt
    payload = { user_id: id, exp: 1.hour.from_now.to_i }
    JWT.encode(payload, jwt_secret, "HS256")
  end

  # JWT をデコードして user_id を返す。失敗時は nil
  def self.from_jwt(token)
    payload = JWT.decode(token, jwt_secret, true, algorithms: [ "HS256" ]).first
    find_by(id: payload["user_id"])
  rescue JWT::DecodeError
    nil
  end

  # メールアドレスとパスワードでユーザーを認証して返す。失敗時は例外を raise
  def self.login!(email:, password:)
    user = find_by(email: email)
    raise ActiveRecord::RecordNotFound unless user&.authenticate(password)
    user
  end

  private

  def jwt_secret
    Rails.application.credentials.jwt_secret!
  end

  def self.jwt_secret
    Rails.application.credentials.jwt_secret!
  end
end
