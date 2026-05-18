require_relative '../../spec_helper'

RSpec.describe 'When viewing the staff homepage' do

  context 'when the staff is logged in' do

    it 'it loads successfully' do
      login_as_staff

      save_page

      expect(page.status_code).to eq(200)
    end

    it 'it greets staff by name' do
      login_as_staff

      expect(page).to have_content('Welcome Staff123!!')
    end

    it 'navigates to the staff shop when shop is clicked' do
      login_as_staff

      click_link 'Shop'
      expect(page).to have_current_path('/staff/selectproducts')
    end

    it 'navigates to manage stock when Manage Stock is clicked' do
      login_as_staff

      click_link 'Manage Stock'
      expect(page).to have_current_path('/managestock')
    end

    it 'navigates to orders when View Orders is clicked' do
      login_as_staff

      click_link 'View Orders'
      expect(page).to have_current_path('/staff/orders')
    end

    it 'navigates to refunds when View Refunds is clicked' do
      login_as_staff

      click_link 'View Refunds'
      expect(page).to have_current_path('/refunds')
    end

    it 'logs out when Logout is clicked' do
      login_as_staff

      click_link 'Logout'
      expect(page.current_path).to eq('/login').or eq('/')
    end
  end
end
