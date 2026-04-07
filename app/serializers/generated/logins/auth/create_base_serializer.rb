# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されます。手動で編集しないでください。
# 生成元: api/resolved/openapi/openapi.yaml
# ==============================================================================

module Generated
  module Logins
    module Auth
      class CreateBaseSerializer
        include Alba::Resource
        attributes :token
        attribute :user do |r|
          {
            name: r.user.name,
            email: r.user.email
          }
        end
      end
    end
  end
end
