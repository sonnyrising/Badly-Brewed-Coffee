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
  
  # -------------------------------------------------------------------------
  # Profile Validation Failures
  # -------------------------------------------------------------------------
  context 'when entering a pre-existing username or email' do
    it 'rejects a duplicate username and displays an error message' do
      # Seed a conflicting user in the database
      Users.create(
        Username: 'taken_username',
        Email: 'other@example.com',
        PassHash: BCrypt::Password.create('password')
      )

      visit '/user/settings'
      fill_in 'username', with: 'taken_username'
      click_button 'Save Changes'

      expect(page).to have_content("Sorry, the username 'taken_username' is already taken!")
    end

    it 'rejects a duplicate email address and displays an error message' do
      Users.create(
        Username: 'other_user',
        Email: 'taken_email@example.com',
        PassHash: BCrypt::Password.create('password')
      )

      visit '/user/settings'
      fill_in 'email', with: 'taken_email@example.com'
      click_button 'Save Changes'

      expect(page).to have_content("Sorry, the email 'taken_email@example.com' is already taken!")  
    end
  end
end