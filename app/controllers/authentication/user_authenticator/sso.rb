# frozen_string_literal: true

class Authentication::UserAuthenticator::Sso < Authentication::UserAuthenticator

  def initialize(username: nil, password: nil)
    @authenticated = false
    @username = username
    @password = password
    @token = ::Keycloak::Token.new(Current.token.try(:raw))
  end

  def authenticate!
    return false if @token.access_token.nil?
    return false unless keycloak_signed_in?
    return false unless preconditions?

    true
  end

  def authenticate_by_headers!
    return false unless header_preconditions?

    if user.is_a?(User::Api)
      authenticated = user.authenticate_db(password)
    end
    brute_force_detector.update(authenticated)
    authenticated
  end

  def update_user_info(remote_ip)
    params = { last_login_from: remote_ip }
    params.merge!(keycloak_params) unless root_user?
    super(params)
  end

  def login_path
    sso_path
  end

  def user_logged_in?(session)
    session[:user_id].present? && user_authenticated?(session)
  end

  def keycloak_login
    Keycloak::Client.url_login_redirect(keycloak_login_url, 'code')
  end

  def logged_out_path
    sso_inactive_path
  end

  def recrypt_path
    recrypt_sso_path
  end

  def keycloak_signed_in?
    return false if @token.access_token.nil?

    Keycloak::Client.user_signed_in?(@token.access_token)
  end

  private

  def user_authenticated?(session)
    return true if session[:username] == 'root'

    Keycloak::Client.user_signed_in?(@token.access_token)
  end

  def find_or_create_user
    user = User.find_by(username: username.strip)
    return create_user if user.nil? && keycloak_signed_in?

    user
  end

  def header_preconditions?
    headers_present? && user_valid? && !root_user?
  end

  def headers_present?
    username.present? && password.present?
  end

  def user_valid?
    valid_username? && user.present? && !brute_force_detector.locked?
  end

  def keycloak_login_url
    protocol = Rails.application.config.force_ssl ? 'https://' : 'http://'
    protocol + (ENV['RAILS_HOST_NAME'] || 'localhost:3000') + sso_path
  end

  def keycloak_params
    { provider_uid: @token.provider_uid,
      givenname: @token.givenname,
      surname: @token.surname }
  end

  def username
    @username ||= @token.username
  end

  def create_user
    psb = keycloak_client.find_or_create_pk_secret_base(@token.access_token)
    User::Human.create(
      username: username,
      givenname: @token.givenname,
      surname: @token.surname,
      provider_uid: @token.provider_uid,
      auth: 'keycloak'
    ) { |u| u.create_keypair(keycloak_client.user_pk_secret(psb, @token.access_token)) }
  end

  def preconditions?
    valid_username? && user.present? &&
      !brute_force_detector.locked?
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
