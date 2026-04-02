# frozen_string_literal: true

# Configure ActiveRecord::Encryption keys from environment variables.
# In test environment the keys are set in config/environments/test.rb.
# Run `bin/rails db:encryption:init` to generate keys and add them to credentials,
# or set the following environment variables:
#   AR_ENCRYPTION_PRIMARY_KEY
#   AR_ENCRYPTION_DETERMINISTIC_KEY
#   AR_ENCRYPTION_KEY_DERIVATION_SALT
unless Rails.env.test?
  Rails.application.configure do
    primary_key = ENV["AR_ENCRYPTION_PRIMARY_KEY"] ||
      Rails.application.credentials.dig(:active_record_encryption, :primary_key)
    deterministic_key = ENV["AR_ENCRYPTION_DETERMINISTIC_KEY"] ||
      Rails.application.credentials.dig(:active_record_encryption, :deterministic_key)
    key_derivation_salt = ENV["AR_ENCRYPTION_KEY_DERIVATION_SALT"] ||
      Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt)

    if primary_key && deterministic_key && key_derivation_salt
      config.active_record.encryption.primary_key = primary_key
      config.active_record.encryption.deterministic_key = deterministic_key
      config.active_record.encryption.key_derivation_salt = key_derivation_salt
    end
  end
end
