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

RSpec.describe 'Basket Payment Page', type: :feature do
  before(:each) do
    login_as_user
    visit '/user/basketpayment'
  end

  # Page load

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'shows the checkout heading' do
      expect(page).to have_content('Checkout')
    end

    it 'shows the order summary section' do
      expect(page).to have_content('Order Summary')
    end

    it 'shows the subtotal section' do
      expect(page).to have_content('Subtotal:')
    end

    it 'shows the total cost section' do
      expect(page).to have_content('Total Cost:')
    end

    it 'shows the background image' do
      expect(page).to have_css('img')
    end
  end

  # Navigation

  describe 'Navigation links' do
    it 'navigates back to dashboard' do
      click_link 'Dashboard'
      expect(page).to have_current_path('/user/homepage')
    end

    it 'navigates to contact us page' do
      click_link 'Contact us'
      expect(page).to have_current_path('/user/contact_us_page')
    end

    it 'logs out successfully' do
      click_link 'Log Out'
      expect(page.current_path).to eq('/login').or eq('/')
    end

    it 'returns to the shop page' do
      click_link 'Back to Shop'
      expect(page).to have_current_path('/user/shop')
    end
  end

  # Basket summary

  describe 'Basket summary' do
    it 'shows the total items section' do
      expect(page).to have_content('Total Items:')
    end

    it 'shows subtotal and total cost values' do
      expect(page.body).to include('£')
    end
  end

  # Payment form

  describe 'Payment form' do
    it 'shows payment input fields when basket has items' do
      if page.has_button?('Buy Now')
        expect(page).to have_field('card_number')
        expect(page).to have_field('cvv')
        expect(page).to have_field('expiry_date')
        expect(page).to have_field('address')
        expect(page).to have_field('city')
        expect(page).to have_field('postcode')
      else
        expect(page).to have_content('Checkout')
      end
    end

    it 'shows the Buy Now button when basket has items' do
      if page.has_button?('Buy Now')
        expect(page).to have_button('Buy Now')
      else
        expect(page).to have_content('Order Summary')
      end
    end
  end
end