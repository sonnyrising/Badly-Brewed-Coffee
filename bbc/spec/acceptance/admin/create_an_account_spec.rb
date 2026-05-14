# frozen_string_literal: true

require_relative '../../spec_helper'

def login_as_admin
  visit '/login'
  fill_in 'uname', with: 'admin'
  fill_in 'pword', with: 'admin'
  click_on 'Log in'
end

RSpec.describe 'Admin account creation.' do
  context 'when the admin is logged in' do
    it 'allows an admin to create a new account' do
      login_as_admin

      visit '/admin/accounts/create'

      choose 'Staff'

      fill_in 'username-data', with: 'testuser123'
      fill_in 'email-data', with: 'test@example.com'
      fill_in 'loyaltypoint-data', with: '100'

      click_on "Save"
      
      expect(page).to have_current_path("/admin/accounts")
      expect(page).to have_content("testuser123")
    end
  end
end
