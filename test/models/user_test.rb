# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @tenant = Tenant.create!(name: "テスト家")
  end

  test "is valid with all required attributes" do
    user = User.new(
      tenant: @tenant,
      name: "太郎",
      email: "taro@example.com",
      password: "Password123",
      password_confirmation: "Password123",
      role: :admin
    )
    assert user.valid?
  end

  test "is invalid without a name" do
    user = User.new(tenant: @tenant, email: "taro@example.com", password: "Password123")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "is invalid without an email" do
    user = User.new(tenant: @tenant, name: "太郎", password: "Password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "is invalid with a malformed email" do
    user = User.new(tenant: @tenant, name: "太郎", email: "not-an-email", password: "Password123")
    assert_not user.valid?
  end

  test "is invalid with duplicate email" do
    User.create!(tenant: @tenant, name: "花子", email: "dup@example.com", password: "Password123", role: :admin)
    user = User.new(tenant: @tenant, name: "太郎", email: "dup@example.com", password: "Password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "is invalid with a short password" do
    user = User.new(tenant: @tenant, name: "太郎", email: "taro@example.com", password: "short")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "authenticates with correct password" do
    user = User.create!(tenant: @tenant, name: "太郎", email: "taro@example.com", password: "Password123", role: :admin)
    assert user.authenticate("Password123")
    assert_not user.authenticate("WrongPassword")
  end
end
