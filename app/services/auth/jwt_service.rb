# frozen_string_literal: true

module Auth
  class JwtService
    ALGORITHM = "HS256"

    class << self
      def encode(payload, exp = 24.hours.from_now)
        payload = payload.merge(exp: exp.to_i)
        JWT.encode(payload, secret_key, ALGORITHM)
      end

      def decode(token)
        decoded = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
        HashWithIndifferentAccess.new(decoded.first)
      rescue JWT::DecodeError => e
        raise ArgumentError, e.message
      end

      private

      def secret_key
        Rails.application.secret_key_base
      end
    end
  end
end
