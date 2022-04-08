# frozen_string_literal: true

require 'concourse'
require 'time'
require 'faker'
require 'jwt'
require 'openssl'

module Build
  module Data
    def self.random_iso8601_future_date
      now = Time.now
      one_hour_in_seconds = 60 * 60
      jitter = Faker::Number.between(from: 30, to: 180)

      (now + one_hour_in_seconds + jitter).iso8601
    end

    def self.random_username
      Faker::Internet.username(
        specifier: "#{Faker::Name.first_name} #{Faker::Name.last_name}"
      )
    end

    def self.random_email
      Faker::Internet.email
    end

    def self.random_issuer
      Faker::Internet.url
    end

    def self.random_subject
      Faker::Alphanumeric.alphanumeric(number: 30)
    end

    def self.random_access_token_hash
      Faker::Alphanumeric.alphanumeric(number: 22)
    end

    def self.random_id_token(overrides = {}, options = {})
      payload = random_id_token_payload(overrides)
      key = OpenSSL::PKey::RSA.generate(512)
      algorithm = options[:algorithm] || 'RS256'

      JWT.encode(payload, key, algorithm)
    end

    # rubocop:disable Metrics/MethodLength
    def self.random_id_token_payload(overrides = {})
      one_hour_in_seconds = 60 * 60

      default_username = random_username
      default_issuer = random_issuer
      default_subject = random_subject
      default_audience = 'fly'
      default_email = random_email
      default_email_verified_flag = true
      default_at_hash = random_access_token_hash
      default_connector_id = 'local'
      default_expiration_time = (Time.now + one_hour_in_seconds).to_i

      {
        iss: default_issuer,
        sub: default_subject,
        aud: default_audience,
        exp: default_expiration_time,
        email: default_email,
        email_verified: default_email_verified_flag,
        at_hash: default_at_hash,
        federated_claims: {
          connector_id: default_connector_id,
          user_id: default_username,
          user_name: default_username
        }
      }.merge(overrides)
    end
    # rubocop:enable Metrics/MethodLength

    def self.random_access_token
      Faker::Alphanumeric.alphanumeric(number: 38)
    end

    def self.random_token(overrides = {})
      Concourse::Models::Token.new({
        access_token: random_access_token,
        token_type: 'bearer',
        expires_at: random_iso8601_future_date,
        id_token: random_id_token
      }.merge(overrides))
    end
  end
end
