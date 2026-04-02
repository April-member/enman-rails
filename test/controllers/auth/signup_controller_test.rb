# frozen_string_literal: true

require "test_helper"

class Auth::SignupControllerTest < ActionDispatch::IntegrationTest
  test "creates tenant and user successfully" do
    post auth_signup_path, params: {
      tenant_name: "田中家",
      user_name: "太郎",
      email: "taro@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    }, as: :json

    assert_response :created
    json = response.parsed_body
    assert_equal "太郎", json.dig("data", "user", "name")
    assert_equal "taro@example.com", json.dig("data", "user", "email")
    assert_not_nil json.dig("data", "user", "id")
    assert_equal "田中家", json.dig("data", "tenant", "name")
    assert_not_nil json.dig("data", "tenant", "id")
    assert_not_nil json.dig("data", "token")
  end

  test "creates tenant and user in the database" do
    assert_difference [ "Tenant.count", "User.count" ], 1 do
      post auth_signup_path, params: {
        tenant_name: "鈴木家",
        user_name: "次郎",
        email: "jiro@example.com",
        password: "Password123",
        password_confirmation: "Password123"
      }, as: :json
    end

    user = User.find_by(email: "jiro@example.com")
    assert user.admin?
    assert_equal "鈴木家", user.tenant.name
  end

  test "returns 422 for duplicate email" do
    tenant = Tenant.create!(name: "先行テナント")
    User.create!(
      tenant: tenant,
      name: "花子",
      email: "taro@example.com",
      password: "Password123",
      role: :admin
    )

    post auth_signup_path, params: {
      tenant_name: "田中家",
      user_name: "太郎",
      email: "taro@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    }, as: :json

    assert_response :unprocessable_entity
    json = response.parsed_body
    assert json["errors"].any?
  end

  test "returns 422 for password confirmation mismatch" do
    post auth_signup_path, params: {
      tenant_name: "田中家",
      user_name: "太郎",
      email: "taro@example.com",
      password: "Password123",
      password_confirmation: "DifferentPass456"
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "returns 422 when tenant_name is blank" do
    post auth_signup_path, params: {
      tenant_name: "",
      user_name: "太郎",
      email: "taro@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "rolls back tenant creation when user is invalid" do
    assert_no_difference "Tenant.count" do
      post auth_signup_path, params: {
        tenant_name: "田中家",
        user_name: "太郎",
        email: "not-an-email",
        password: "Password123",
        password_confirmation: "Password123"
      }, as: :json
    end
  end
end
