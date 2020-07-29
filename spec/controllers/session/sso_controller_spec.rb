# frozen_string_literal: true

require 'rails_helper'

describe Session::SsoController do
  include ControllerHelpers

  let(:token_ben) { Rails.root.join('spec/fixtures/files/auth/keycloak_token_ben.json').read }
  let(:token_bob) { Rails.root.join('spec/fixtures/files/auth/keycloak_token_bob.json').read }

  context 'GET sso' do

    it 'logs in User with Keycloak' do
      enable_keycloak
      Rails.application.reload_routes!

      expect(Keycloak::Client).to receive(:get_token_by_code)
        .and_return(token_ben)
        .at_least(:once)
      expect(Keycloak::Client)
        .to receive(:user_signed_in?)
        .at_least(:once)
        .and_return(true)

      get :create, params: { code: 'asd' }
      expect(response).to redirect_to root_path
      user = User.find_by(username: 'ben')
      expect(user.username).to eq('ben')
      expect(session['username']).to eq('ben')
      expect(session['private_key']).to_not be_nil
    end

    it 'redirects to keycloak if not logged in' do
      enable_keycloak
      Rails.application.reload_routes!

      expect_any_instance_of(Authentication::UserAuthenticator::Sso)
        .to receive(:keycloak_login).and_return(sso_path)

      get :create
    end

    it 'redirects to normal login if keycloak disabled' do
      Rails.application.reload_routes!

      expect do
        get :create, params: { code: 'asd' }
      end.to raise_error(ActionController::UrlGenerationError)
    end

    it 'redirects to migration if user is not keycloak' do
      enable_keycloak
      Rails.application.reload_routes!

      expect(Keycloak::Client)
        .to receive(:get_token_by_code)
        .and_return(token_bob)
      expect(Keycloak::Client)
        .to receive(:user_signed_in?)
        .at_least(:once)
        .and_return(true)

      get :create, params: { code: 'asd' }

      expect(response).to redirect_to recrypt_sso_path
    end
  end
end
