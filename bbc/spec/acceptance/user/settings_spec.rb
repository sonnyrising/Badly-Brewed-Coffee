# frozen_string_literal: true

require 'capybara/rspec'
require 'rack/test'
require_relative '../../spec_helper'
require_relative '../../../app'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_test_user(username)
  user = Users.find(Username: username) || Users.create(
    Username: username,
    Email: 'test@example.com',
    PassHash: BCrypt::Password.create('password'),
    LoyaltyPoints: 10,
    Suspended: 0,
    DateJoined: '01/01/2026'
  )
  
  visit '/login'
  fill_in 'uname', with: username
  fill_in 'pword', with: 'password'
  click_button 'Log in'
  user
end

RSpec.describe 'User Account Settings Flow', type: :feature do
  before(:each) do
    Users.dataset.delete
    @user = login_as_test_user('original_name')
  end

  # -------------------------------------------------------------------------
  # ic Data Display
  # -------------------------------------------------------------------------
  context 'when viewing the profile configuration layout' do
    it 'accurately extracts  loyalty data' do
      visit '/user/settings'

      expect(page.status_code).to eq(200)
      expect(page).to have_content('Loyalty Points: 10')
    end
  end

  # -------------------------------------------------------------------------
  # Successful Profile Updates
  # -------------------------------------------------------------------------
  context 'when entering valid registration modifications' do
    it 'commits changes to the  database and confirms with success flash' do
      visit '/user/settings'

      fill_in 'username', with: 'new_name'
      fill_in 'email', with: 'updated_email@example.com'
      click_button 'Save Changes'

      expect(page).to have_content('Account details successfully updated!')
      
      expect(page).to have_field('username', with: 'new_name')
      expect(page).to have_field('email', with: 'updated_email@example.com')
    end
  end
end