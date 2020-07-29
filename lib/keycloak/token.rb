# frozen_string_literal: true

module Keycloak
  class Token
    class << self
      def issue!(code, url)
        token = Client.get_token_by_code(code, url)
        new(JSON.parse(token))
      end

      def refresh!(token)
        token = Client.get_token_by_refresh_token(token.refresh_token)
        new(JSON.parse(token))
      end
    end

    attr_accessor :raw, :now

    def initialize(raw)
      @raw = raw
      @now = Time.zone.now
    end

    def expired?
      access_token.nil? || (now > access_expires_at)
    end

    def refresh?
      refresh_token.nil? || (now > access_expires_at && now < refresh_expires_at)
    end

    def access_token
      raw.try(:[], 'access_token')
    end

    def refresh_token
      raw.try(:[], 'refresh_token')
    end

    def username
      decoded_access_token['preferred_username']
    end

    def givenname
      decoded_access_token['given_name']
    end

    def surname
      decoded_access_token['family_name']
    end

    def provider_uid
      decoded_access_token['sub']
    end

    def pk_secret_base
      decoded_access_token['pk_secret_base']
    end

    private

    def issued_at
      Time.zone.at(decoded_access_token['iat'])
    end

    def access_expires_at
      issued_at + raw['expires_in']
    end

    def refresh_expires_at
      issued_at + raw['refresh_expires_in']
    end

    def decoded_access_token
      @decoded_access_token ||= Client.decoded_access_token(access_token).first
    end
  end
end
