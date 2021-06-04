# frozen_string_literal: true

class Api::Profile::PasswordController < ApiController
  self.permitted_attrs = [:old_password, :new_password1, :new_password2]

  before_action :authorize_action

  def update
    if password_params_valid?
      current_user.update_password(old_password,
                                   new_password)
      add_info('flashes.session.new_password_set')
    end
    render_json
  end

  def password_params_valid?
    return if current_user.is_a?(User::Api)

    unless current_user.authenticate_db(old_password)
      add_error('flashes.session.wrong_password')
      return false
    end

    unless new_passwords_match?
      add_error('flashes.session.new_passwords_not_equal')
      return false
    end
    true
  end

  private

  def old_password
    model_params[:old_password]
  end

  def new_password
    model_params[:new_password1] if new_passwords_match?
  end

  def new_passwords_match?
    model_params[:new_password1] == model_params[:new_password2]
  end

  def authorize_action
    authorize :'Profile::Password'
  end
end
