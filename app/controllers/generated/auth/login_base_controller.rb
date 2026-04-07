# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されます。手動で編集しないでください。
# 生成元: api/resolved/openapi/openapi.yaml
# ==============================================================================

module Generated
  class Auth::LoginBaseController < ApplicationController
    # --------------------------------------------------------------------------
    # Actions
    # --------------------------------------------------------------------------

    # POST /auth/login (operationId: authLogin)

    def create
      resource = Data.define(:user, :token).new(user: {"name" => "太郎", "email" => "taro@example.com"}, token: "eyJhbGciOiJIUzI1NiJ9...")
      render json: ::Logins::CreateSerializer.new(resource).serialize, status: :ok
    end

    private

    # Strong Parameters
    def login_params
      params.permit(:email, :password)
    end

  end
end
