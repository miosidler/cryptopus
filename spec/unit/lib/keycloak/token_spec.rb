# frozen_string_literal: true

require 'rails_helper'

describe Keycloak::Token do
  let(:json_token) { Rails.root.join('spec/fixtures/files/auth/keycloak_token_bob.json').read }
  let(:raw) { JSON.parse(Rails.root.join('spec/fixtures/files/auth/keycloak_token_bob.json').read) }

  context 'class methods!' do
    let(:code) { '123' }
    let(:new_session_url) { 'http://example.com/de/session/new' }

    it 'issue returns token' do
      expect(Keycloak::Client).to receive(:get_token_by_code)
        .with(code, new_session_url)
        .and_return(json_token)

      token = Keycloak::Token.issue!(code, new_session_url)
      expect(token).to be_instance_of(Keycloak::Token)
    end

    it 'refresh returns token' do
      expect(Keycloak::Client).to receive(:get_token_by_refresh_token).and_return(json_token)
      token = Keycloak::Token.new(raw)
      new_token = Keycloak::Token.refresh!(token)
      expect(new_token).to be_instance_of(Keycloak::Token)
    end
  end

  context 'instance methods' do
    it 'reads User data from token' do
      token = Keycloak::Token.new(raw)

      expect(token.username).to eq('bob')
      expect(token.givenname).to eq('Bob')
      expect(token.surname).to eq('Muster')
      expect(token.pk_secret_base).to eq('w0iCpFju/sJVd2BVf2M1TvUUuY1YwCWMG5quD0XEG20=')
      expect(token.provider_uid).to eq('1f093eb6-a09a-4945-b0b4-d1ecec781a5f')
    end

    it 'token is not expired' do
      token = Keycloak::Token.new(raw)

      expect(token).to receive(:issued_at).and_return(Time.zone.now)
      expect(token.expired?).to be false
    end

    it 'token is expired after 5 minutes' do
      token = Keycloak::Token.new(raw)

      expect(token).to receive(:issued_at).and_return(Time.zone.now - 6 * 60)
      expect(token.expired?).to be true
    end
  end
end
