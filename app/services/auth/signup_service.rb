# frozen_string_literal: true

module Auth
  class SignupService
    def initialize(params)
      @tenant_name = params[:tenant_name]
      @user_name = params[:user_name]
      @email = params[:email]
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
    end

    def call
      ActiveRecord::Base.transaction do
        tenant = Tenant.create!(name: @tenant_name)
        user = User.create!(
          tenant: tenant,
          name: @user_name,
          email: @email,
          password: @password,
          password_confirmation: @password_confirmation,
          role: :admin
        )
        token = Auth::JwtService.encode(user_id: user.id, tenant_id: tenant.id)
        { user: user, tenant: tenant, token: token }
      end
    end
  end
end
