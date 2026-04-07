# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されます。手動で編集しないでください。
# 生成元: api/resolved/openapi/openapi.yaml
# ==============================================================================

module Generated
  class Auth::SignupBaseController < ApplicationController
    # --------------------------------------------------------------------------
    # Actions
    # --------------------------------------------------------------------------

    # POST /auth/signup (operationId: authSignup)

    def create
      resource = Data.define(:user, :tenant, :token).new(user: {"name" => "太郎", "id" => 1, "email" => "taro@example.com"}, tenant: {"name" => "田中家"}, token: "eyJhbGciOiJIUzI1NiJ9...")
      render json: ::Signups::CreateSerializer.new(resource).serialize, status: :created
    end

    private

    # Strong Parameters
    def signup_params
      params.permit(:tenant_name, :user_name, :email, :password, :password_confirmation)
    end

  end
end
