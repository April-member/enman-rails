# frozen_string_literal: true

module Auth
  class SignupController < ApplicationController
    def create
      result = Auth::SignupService.new(signup_params).call
      render json: {
        data: {
          user: { id: result[:user].id, name: result[:user].name, email: result[:user].email },
          tenant: { id: result[:tenant].id, name: result[:tenant].name },
          token: result[:token]
        }
      }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def signup_params
      params.permit(:tenant_name, :user_name, :email, :password, :password_confirmation)
    end
  end
end
