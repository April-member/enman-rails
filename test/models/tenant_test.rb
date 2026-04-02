# frozen_string_literal: true

require "test_helper"

class TenantTest < ActiveSupport::TestCase
  test "is valid with a name" do
    tenant = Tenant.new(name: "田中家")
    assert tenant.valid?
  end

  test "is invalid without a name" do
    tenant = Tenant.new(name: "")
    assert_not tenant.valid?
    assert_includes tenant.errors[:name], "can't be blank"
  end

  test "generates invitation_token on create" do
    tenant = Tenant.create!(name: "田中家")
    assert_not_nil tenant.invitation_token
  end

  test "invitation_token is unique per tenant" do
    tenant1 = Tenant.create!(name: "テナント1")
    tenant2 = Tenant.create!(name: "テナント2")
    assert_not_equal tenant1.invitation_token, tenant2.invitation_token
  end
end
