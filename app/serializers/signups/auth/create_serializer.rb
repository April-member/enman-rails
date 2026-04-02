# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されました（初回のみ）。自由に編集してください。
# ベースクラス: Generated::Signups::Auth::CreateBaseSerializer
# ==============================================================================

module Signups
module Auth
  class CreateSerializer < Generated::Signups::Auth::CreateBaseSerializer
    attribute :user do |result|
      { id: result.user.id, name: result.user.name, email: result.user.email }
    end

    attribute :tenant do |result|
      { id: result.tenant.id, name: result.tenant.name }
    end
  end
end
end
