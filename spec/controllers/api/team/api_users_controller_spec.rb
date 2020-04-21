# frozen_string_literal: true

require 'rails_helper'

describe Api::Team::ApiUsersController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:alice) { users(:alice) }

  context 'GET index' do
    it 'lists his api users as user' do
      api_user1 = bob.api_users.create
      api_user2 = bob.api_users.create
      alice.api_users.create
      team = teams(:team1)

      login_as(:bob)

      get :index, params: { team_id: team }, xhr: true

      api_users = json['data']['team/api_users']

      expect(api_users.size).to eq 2
      expect(api_users.first.values[1]).to eq api_user1.username
      expect(api_users.second.values[1]).to eq api_user2.username
    end

    it 'cannot list api users of bob as conf admin' do
      alice.api_users.create
      team = teams(:team1)

      login_as(:bob)

      get :index, params: { team_id: team }, xhr: true

      expect(json['data']['accounts']).to eq nil
    end

    it 'lists bobs api users as admin' do
      api_user1 = bob.api_users.create
      api_user2 = bob.api_users.create
      alice.api_users.create
      team = teams(:team1)

      login_as(:bob)

      get :index, params: { team_id: team }, xhr: true

      api_users = json['data']['team/api_users']

      expect(api_users.size).to eq 2
      expect(api_users.first.values[1]).to eq api_user1.username
      expect(api_users.second.values[1]).to eq api_user2.username
    end
  end

  context 'POST create' do
    it 'enables api user for team as user' do
      api_user1 = bob.api_users.create
      api_user2 = bob.api_users.create
      team = teams(:team1)

      login_as(:bob)

      post :create, params: { team_id: team, id: api_user1.id }, xhr: true

      expect(team.teammember?(api_user1)).to eq true
      expect(team.teammember?(api_user2)).to eq false
    end

    it 'doesnt enable api user for team as conf admin' do
      api_user1 = users(:conf_admin).api_users.create
      api_user2 = users(:conf_admin).api_users.create
      team = teams(:team1)

      login_as(:tux)

      post :create, params: { team_id: team, id: api_user1.id }, xhr: true

      expect(team.teammember?(api_user1)).to eq false
      expect(team.teammember?(api_user2)).to eq false
    end

    it 'enables api user for team as admin' do
      api_user1 = users(:admin).api_users.create
      api_user2 = users(:admin).api_users.create
      team = teams(:team1)

      login_as(:admin)

      post :create, params: { team_id: team, id: api_user1.id }, xhr: true

      expect(team.teammember?(api_user1)).to eq true
      expect(team.teammember?(api_user2)).to eq false
    end
  end

  context 'DELETE destroy' do
    it 'disables api user for team as user' do
      api_user = bob.api_users.create
      team = teams(:team1)
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      login_as(:bob)

      team.add_user(api_user, plaintext_team_password)

      delete :destroy, params: { team_id: team, id: api_user.id }, xhr: true

      expect(team.teammember?(api_user)).to eq false
    end

    it 'cannot disable api user for team as conf admin' do
      api_user = bob.api_users.create
      team = teams(:team1)
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      login_as(:tux)

      team.add_user(api_user, plaintext_team_password)

      delete :destroy, params: { team_id: team, id: api_user.id }, xhr: true

      expect(team.teammember?(api_user)).to eq true
    end

    it 'disables api user for team as admin' do
      api_user = bob.api_users.create
      team = teams(:team1)
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      login_as(:admin)

      team.add_user(api_user, plaintext_team_password)

      delete :destroy, params: { team_id: team, id: api_user.id }, xhr: true

      expect(team.teammember?(api_user)).to eq false
    end
  end
end
