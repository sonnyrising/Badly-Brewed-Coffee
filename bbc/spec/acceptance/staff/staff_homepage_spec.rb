# frozen_string_literal: true

require 'capybara/rspec'
require 'rack/test'

require_relative '../../../app'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_staff
  visit '/login'
  fill_in 'uname', with: 'Staff123!'
  fill_in 'pword', with: 'Staff123!'
  click_button 'Log in'
end

RSpec.describe 'Staff Homepage', type: :feature do
  before(:each) do
    login_as_staff
    visit '/staff/homepage'
  end

  # -------------------------------------------------------------------------
  # Page load
  # -------------------------------------------------------------------------

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'greets staff by name' do
      expect(page).to have_content('Welcome Staff123!!')
    end
  end


  # -------------------------------------------------------------------------
  # Sidebar navigation
  # -------------------------------------------------------------------------

  describe 'Sidebar navigation' do
    it 'navigates to the staff shop when shop is clicked' do
      click_link 'Shop'
      expect(page).to have_current_path('/staff/selectproducts')
    end

    it 'navigates to manage stock when Manage Stock is clicked' do
      click_link 'Manage Stock'
      expect(page).to have_current_path('/managestock')
    end

    it 'navigates to orders when View Orders is clicked' do
      click_link 'View Orders'
      expect(page).to have_current_path('/orders')
    end

    it 'navigates to refunds when View Refunds is clicked' do
      click_link 'View Refunds'
      expect(page).to have_current_path('/refunds')
    end

    it 'logs out when Logout is clicked' do
      click_link 'Logout'
      expect(page.current_path).to eq('/login').or eq('/')
    end
  end

  # -------------------------------------------------------------------------
  # Access control
  # -------------------------------------------------------------------------

  describe 'Access control' do
    context 'when visiting without any session' do
      before do
        Capybara.reset_sessions!
        visit '/staff/homepage'
      end

      it 'redirects to the login page' do
        expect(page.current_path).to eq('/login')
      end
    end
  end
end
