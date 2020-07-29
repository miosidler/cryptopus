# frozen_string_literal: true

require 'rails_helper'

describe KeycloakClient do

  let(:raw) { JSON.parse(Rails.root.join('spec/fixtures/files/auth/keycloak_token_bob.json').read) }

  it 'returns user pk_secret' do
    keyclaok_client = KeycloakClient.new

    Current.token = Keycloak::Token.new(raw)

    expect(keyclaok_client.user_pk_secret)
    .to eq('8eb31f504ebb9fe633b92bbd93b135ce75b3d063d9766c0e47a35ebfb013230e69418ad480920f6fd93a14165d5f16dce0c0f77545930afb5c1df6f3db1bc972')
  end
end
