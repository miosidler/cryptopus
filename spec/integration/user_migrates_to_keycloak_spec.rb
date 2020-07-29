# frozen_string_literal: true

require 'rails_helper'

describe 'User migrates to keycloak spec' do
  include IntegrationHelpers::DefaultHelper

  before do
    enable_keycloak
    Rails.application.reload_routes!
    @pk_secret_base = SecureRandom.base64(32)
  end

  let(:token_bob) { Rails.root.join('spec/fixtures/files/auth/keycloak_token_bob.json').read }

  it 'migrates db bob to keycloak' do
    # Mock
    expect(Keycloak::Client)
      .to receive(:url_login_redirect)
      .at_least(:once)
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .at_least(:once)
      .and_return(token_bob)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .at_least(:once)
      .and_return(true)

    # login
    get root_path
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso')
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    expect(request.fullpath).to eq('/recrypt/sso')
    post recrypt_sso_path, params: { old_password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    # Adjust test to new start-page:
    expect(request.fullpath).to eq(root_path)
    expect(response.body).to match(/<div id='ember'><\/div>/)
  end

  it 'migrates ldap bob to keycloak' do
    users(:bob).update!(auth: 'ldap', password: nil)
    # Mock
    expect(Keycloak::Client)
      .to receive(:url_login_redirect)
      .at_least(:once)
      .with(sso_url, 'code')
      .and_return(sso_path(code: 'asd'))
    expect(Keycloak::Client)
      .to receive(:get_token_by_code)
      .at_least(:once)
      .and_return(token_bob)
    expect(Keycloak::Client).to receive(:user_signed_in?)
      .at_least(:once)
      .and_return(true)

    # login
    get root_path
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso')
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    expect(request.fullpath).to eq('/recrypt/sso')
    post recrypt_sso_path, params: { old_password: 'password' }
    follow_redirect!
    expect(request.fullpath).to eq('/session/sso?code=asd')
    follow_redirect!
    # Adjust test to new start-page:
    expect(request.fullpath).to eq(root_path)
    expect(response.body).to match(/<div id='ember'><\/div>/)
  end
end
