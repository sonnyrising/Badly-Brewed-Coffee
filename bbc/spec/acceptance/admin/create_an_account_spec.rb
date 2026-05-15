# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe 'Admin account creation.' do
  context 'when the admin is logged in' do
    it 'allows an admin to create a new account' do
      login_as_admin
      visit '/admin/accounts/create'

      choose 'staffoption'

      fill_in 'username-data', with: 'testuser123'
      fill_in 'email-data', with: 'test@example.com'
      fill_in 'loyaltypoint-data', with: '100'

      click_on "Save"
      
      expect(page).to have_current_path("/admin/accounts")
      expect(page).to have_content("testuser123")
    end
  end
end
