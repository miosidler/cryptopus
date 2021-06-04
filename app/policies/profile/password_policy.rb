# frozen_string_literal: true

class Profile::PasswordPolicy < ApplicationPolicy
  def update?
    user.auth_db?
  end
end
