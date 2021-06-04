# frozen_string_literal: true

require 'spec_helper'

describe Api::Profile::PasswordController do
  include ControllerHelpers

  context 'POST update_password' do
    it 'updates password' do
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(json['info']).to include('flashes.session.new_password_set')
      expect(users(:bob).authenticate_db('test')).to eq true
    end

    it 'updates password, error if oldpassword not match' do
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'wrong_password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(json['errors']).to include('flashes.session.wrong_password')
      expect(users(:bob).authenticate_db('test')).to be false
    end

    it 'updates password, error if new passwords not match' do
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'wrong_password' }
        }
      }
      patch :update, params: password_params

      expect(json['errors']).to include('flashes.session.new_passwords_not_equal')
      expect(users(:bob).authenticate_db('test')).to eq false
    end

    it 'returns unauthorized if ldap user tries to update password' do
      users(:bob).update!(auth: 'ldap')
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(response).to have_http_status(403)
    end

    it 'returns unauthorized if oidc user tries to update password' do
      users(:bob).update!(auth: 'oidc')
      login_as(:bob)
      password_params = {
        data: {
          attributes: { old_password: 'password',
                        new_password1: 'test',
                        new_password2: 'test' }
        }
      }
      patch :update, params: password_params

      expect(response).to have_http_status(403)
    end
  end
end
