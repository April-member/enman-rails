class ApplicationController < ActionController::API
  private

  # 認証が必要なエンドポイントに before_action として使う
  def authenticate_user!
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")
    @current_user = User.from_jwt(token) if token
    render json: { errors: { base: [ "Unauthorized" ] } }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
