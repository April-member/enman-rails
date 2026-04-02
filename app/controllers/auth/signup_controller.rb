# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されました（初回のみ）。自由に編集してください。
# ベースクラス: Generated::Auth::SignupBaseController
# ==============================================================================

class Auth::SignupController < Generated::Auth::SignupBaseController
  def create
    tenant, user = Tenant.signup!(signup_params)
    render json: ::Signups::Auth::CreateSerializer.new(build_result(tenant, user)).serialize, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  end

  private

  SignupResult = Data.define(:tenant, :user, :token)

  def build_result(tenant, user)
    SignupResult.new(tenant:, user:, token: "TODO")
  end
end
