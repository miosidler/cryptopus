# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Session::SsoController < SessionController

  layout 'session', only: :inactive

  def create
    if !params.key?(:code) && cookies[:keycloak_token].nil?
      return redirect_to user_authenticator.keycloak_login
    end

    if params.key?(:code)
      Current.token = Keycloak::Token.issue!(params[:code], sso_url)
      cookies.permanent[:keycloak_token] = Current.json_token
    end

    unless user_authenticator.authenticate!
      return redirect_to user_authenticator.login_path
    end

    unless create_session(keycloak_client.user_pk_secret(nil, Current.token.raw['access_token']))
      return redirect_if_decryption_error
    end

    redirect_after_sucessful_login
  end

  def inactive
    flash[:notice] = t('session.sso.inactive.inactive')
  end

  private

  def redirect_if_decryption_error
    return redirect_to user_authenticator.recrypt_path unless current_user.keycloak?

    reset_session_before_redirect
    redirect_to user_authenticator.keycloak_login
  end

  def reset_session_before_redirect
    jumpto = session[:jumpto]
    reset_session
    session[:jumpto] = jumpto
  end

  def authorize_action
    authorize :sso
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
