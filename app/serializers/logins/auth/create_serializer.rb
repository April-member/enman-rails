# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されました（初回のみ）。自由に編集してください。
# ベースクラス: Generated::Logins::Auth::CreateBaseSerializer
# ==============================================================================

module Logins
module Auth
  class CreateSerializer < Generated::Logins::Auth::CreateBaseSerializer
    attribute :user do |result|
      { id: result.user.id, name: result.user.name, email: result.user.email }
    end

    attribute :token do |result|
      result.token
    end
  end
end
end
