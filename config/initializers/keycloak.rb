if AuthConfig.keycloak_enabled?
  # If true, then all request exception will explode in application (this is the default value)
  Keycloak.generate_request_exception = true
  # controller that manage the user session
  Keycloak.keycloak_controller = "sessions"
  # The introspect of the token will be executed every time the Keycloak::Client.has_role? method is invoked, if this setting is set to true.
  Keycloak.validate_token_when_call_has_role = false
  # resource (client_id, only if the installation file is not present)
  Keycloak.proc_cookie_token = lambda do
    Current.token
  end
end
