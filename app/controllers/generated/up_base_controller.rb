# frozen_string_literal: true

# ==============================================================================
# このファイルは自動生成されます。手動で編集しないでください。
# 生成元: api/resolved/openapi/openapi.yaml
# ==============================================================================

module Generated
  class UpBaseController < ApplicationController
    # --------------------------------------------------------------------------
    # Actions
    # --------------------------------------------------------------------------

    # GET /up (operationId: up)

    def index
      resource = Data.define(:message, :test).new(message: "I'm up!", test: 123)
      render json: ::Ups::IndexSerializer.new(resource).serialize, status: :ok
    end

  end
end
