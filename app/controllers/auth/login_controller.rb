# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されました（初回のみ）。自由に編集してください。
# ベースクラス: Generated::Auth::LoginBaseController
# ==============================================================================

class Auth::LoginController < Generated::Auth::LoginBaseController
  def create
    user = User.login!(**login_params.to_h.symbolize_keys)
    render json: ::Logins::Auth::CreateSerializer.new(build_result(user)).serialize, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { errors: { base: [ "メールアドレスまたはパスワードが正しくありません" ] } }, status: :unauthorized
  end

  private

  LoginResult = Data.define(:user, :token)

  def build_result(user)
    LoginResult.new(user:, token: user.generate_jwt)
  end
end
