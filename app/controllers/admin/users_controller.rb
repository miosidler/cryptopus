# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::UsersController < ApplicationController
  before_action :redirect_if_non_db_user, only: [:update, :edit]
  before_action :authorize_user_class, only: [:index, :new, :create]
  before_action :authorize_user, only: [:update, :unlock, :edit]

  # POST /admin/users
  def create
    @user = User::Human.create_db_user(password, permitted_attributes(User::Human))

    respond_to do |format|
      if @user.save
        flash[:notice] = t('flashes.admin.users.created')
        format.html { redirect_to admin_users_url }
      else
        format.html { render action: 'new' }
      end
    end
  end

  private

  def redirect_if_non_db_user
    return if user.auth_db?

    flash[:error] = t('flashes.admin.users.update.not_db')

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  def user
    @user ||= User::Human.find(params[:id])
  end

  def password
    params[:user_human][:password]
  end

  def authorize_user_class
    authorize User::Human
  end

  def authorize_user
    authorize user
  end
end
