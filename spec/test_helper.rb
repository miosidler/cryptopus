# frozen_string_literal: true

def decrypt_private_key(user)
  user.decrypt_private_key('password')
end

def legacy_encrypt_private_key(private_key, password)
  cipher = OpenSSL::Cipher.new('aes-256-cbc')
  cipher.encrypt
  cipher.key = password.unpack('a2' * 32).map { |x| x.hex }.pack('c' * 32)
  encrypted_private_key = cipher.update(private_key)
  encrypted_private_key << cipher.final
  encrypted_private_key
end

def enable_keycloak
  expect_any_instance_of(AuthConfig)
    .to receive(:settings_file)
    .at_least(:once)
    .and_return(provider: 'keycloak')
end

def enable_ldap
  expect_any_instance_of(AuthConfig)
    .to receive(:settings_file)
    .at_least(:once)
    .and_return(provider: 'ldap')
end

def stub_geo_ip
  allow(GeoIp).to receive(:activated?).at_least(:once).and_return(nil)
end

def mock_ldap_settings
  allow(AuthConfig).to receive(:ldap_settings).and_return(ldap_settings).at_least(:once)
end

def update_token(token)
  parsed_token = JSON.parse(token)
  access_token = Keycloak::Client.decoded_access_token(parsed_token['access_token']).first
  refresh_token = Keycloak::Client.decoded_access_token(parsed_token['refresh_token']).first
  rsa_private = OpenSSL::PKey::RSA.generate 2048
  access_token['iat'] = refresh_token['iat'] = Time.zone.now.to_i
  parsed_token['access_token'] = JWT.encode(access_token, rsa_private, 'RS256')
  parsed_token['refresh_token'] = JWT.encode(refresh_token, rsa_private, 'RS256')
  parsed_token.to_json
end

def ldap_settings
  {
    bind_dn: 'example_bind_dn',
    bind_password: 'ZXhhbXBsZV9iaW5kX3Bhc3N3b3Jk',
    encryption: 'simple_tls',
    hostnames: ['example_hostname'],
    basename: 'ou=users,dc=acme',
    portnumber: 636
  }
end
