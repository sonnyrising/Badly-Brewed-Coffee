# frozen_string_literal: true

require 'capybara/rspec'
require 'rack/test'

require_relative '../../../app'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_user
  visit '/login'
  fill_in 'uname', with: 'User123!'
  fill_in 'pword', with: 'User123!'
  click_button 'Log in'
end

RSpec.describe 'User Dashboard Homepage', type: :feature do
  before(:each) do
    login_as_user
    visit '/user/homepage'
  end

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'greets the user by username' do
      expect(page).to have_content('Welcome, User123!')
    end

    it 'shows the loyalty section' do
      expect(page).to have_content('Loyalty points')
    end

    it 'shows the company history section' do
      expect(page).to have_content('History of BBC')
    end

    it 'shows the recent transaction section' do
      expect(page).to have_content('Most Recent Transaction')
    end
  end

  describe 'Navigation bar' do
    it 'navigates to dashboard when Dashboard is clicked' do
      click_link 'Dashboard'
      expect(page).to have_current_path('/user/homepage')
    end

    it 'navigates to bean shop when Bean Shop is clicked' do
      click_link 'Bean Shop'
      expect(page).to have_current_path('/user/shop')
    end

    it 'navigates to coffee shop when Coffee Shop is clicked' do
      click_link 'Coffee Shop'
      expect(page).to have_current_path('/user/coffeeshop')
    end

    it 'navigates to orders when Orders is clicked' do
      click_link 'Orders'
      expect(page).to have_current_path('/user/orders')
    end

    it 'navigates to settings when Settings is clicked' do
      click_link 'Settings'
      expect(page).to have_current_path('/user/settings')
    end

    it 'navigates to contact us page when Contact Us is clicked' do
      click_link 'Contact Us'
      expect(page).to have_current_path('/user/contact_us_page')
    end

    it 'logs out when Logout is clicked' do
      click_link 'Logout'
      expect(page.current_path).to eq('/login').or eq('/')
    end
  end

  # -------------------------------------------------------------------------
  # Loyalty card
  # -------------------------------------------------------------------------

  describe 'Loyalty card section' do
    it 'shows the loyalty reward message' do
      expect(page).to have_content(
        'Get 10 stamps for up to £5 off your next coffee!'
      )
    end

    it 'displays loyalty stamp slots' do
      expect(page).to have_css('.stamp-slot', minimum: 1)
    end
  end

  # Recent transaction section

  describe 'Recent transaction section' do
    it 'shows the recent transaction title' do
      expect(page).to have_content('Most Recent Transaction')
    end

    it 'shows transaction information when orders exist' do
      if page.has_content?('No recent transactions found.')
        expect(page).to have_content('No recent transactions found.')
      else
        expect(page).to have_content('Product')
        expect(page).to have_content('Quantity')
        expect(page).to have_content('Price (each)')
        expect(page).to have_content('Subtotal')
        expect(page).to have_content('Total Paid:')
      end
    end
  end
end

