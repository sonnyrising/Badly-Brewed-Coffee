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

RSpec.describe 'User Shop Pages', type: :feature do
  before(:each) do
    login_as_user
  end

  # Bean Shop

  describe 'Bean Shop page' do
    before(:each) do
      visit '/user/shop'
    end

    describe 'Page load' do
      it 'loads successfully' do
        expect(page.status_code).to eq(200)
      end

      it 'shows the Beans' do
        expect(page).to have_content('Beans')
      end

      it 'shows the checkout button' do
        expect(page).to have_button('Checkout')
      end

      it 'shows the search bar' do
        expect(page).to have_field('search')
      end

      it 'shows the roast dropdown' do
        expect(page).to have_select('roast')
      end

      it 'shows the basket icon' do
        expect(page).to have_css('.basket-img')
      end

      it 'shows the product display grid' do
        expect(page).to have_css('.product-inner-grid')
      end
    end

    # Navigation

    describe 'Navigation bar' do
      it 'navigates to dashboard' do
        click_link 'Dashboard'
        expect(page).to have_current_path('/user/homepage')
      end

      it 'navigates to bean shop' do
        click_link 'Bean Shop'
        expect(page).to have_current_path('/user/shop')
      end

      it 'navigates to coffee shop' do
        click_link 'Coffee Shop'
        expect(page).to have_current_path('/user/coffeeshop')
      end

      it 'navigates to orders page' do
        click_link 'Orders'
        expect(page).to have_current_path('/user/orders')
      end

      it 'navigates to settings page' do
        click_link 'Settings'
        expect(page).to have_current_path('/user/settings')
      end

      it 'navigates to contact us page' do
        click_link 'Contact Us'
        expect(page).to have_current_path('/user/contact_us_page')
      end
    end

    # Filtering

    describe 'Filtering beans' do
      it 'filters products using search input' do
        fill_in 'search', with: 'Coffee'
        click_button 'Search'

        expect(page.status_code).to eq(200)
      end

      it 'filters products using roast dropdown' do
        select 'Light Roast', from: 'roast'
        click_button 'Search'

        expect(page.status_code).to eq(200)
      end

      it 'clears the filter' do
        click_button 'Clear'

        expect(page.status_code).to eq(200)
      end
    end

    # Basket

    describe 'Basket sidebar' do
      it 'shows the basket quantity badge' do
        expect(page).to have_css('.basket-count-badge')
      end

      it 'shows quantity buttons if basket items exist' do
        expect(page.body).to satisfy do |body|
          body.include?('qty-btn') || body.include?('Checkout')
        end
      end
    end
  end

  # Coffee Shop

  describe 'Coffee Shop page' do
    before(:each) do
      visit '/user/coffeeshop'
    end

    describe 'Page load' do
      it 'loads successfully' do
        expect(page.status_code).to eq(200)
      end

      it 'shows the Coffees title' do
        expect(page).to have_content('Coffees')
      end

      it 'shows the checkout button' do
        expect(page).to have_button('Checkout')
      end

      it 'shows the search bar' do
        expect(page).to have_field('search')
      end

      it 'shows the roast dropdown' do
        expect(page).to have_select('roast')
      end

      it 'shows the basket icon' do
        expect(page).to have_css('.basket-img')
      end

      it 'shows coffee products on the page' do
        expect(page).to have_css('.product-box', minimum: 1)
      end
    end

    # Navigation

    describe 'Navigation bar' do
      it 'navigates to dashboard' do
        click_link 'Dashboard'
        expect(page).to have_current_path('/user/homepage')
      end

      it 'navigates to bean shop' do
        click_link 'Bean Shop'
        expect(page).to have_current_path('/user/shop')
      end

      it 'navigates to coffee shop' do
        click_link 'Coffee Shop'
        expect(page).to have_current_path('/user/coffeeshop')
      end

      it 'navigates to orders page' do
        click_link 'Orders'
        expect(page).to have_current_path('/user/orders')
      end

      it 'navigates to settings page' do
        click_link 'Settings'
        expect(page).to have_current_path('/user/settings')
      end

      it 'navigates to contact us page' do
        click_link 'Contact Us'
        expect(page).to have_current_path('/user/contact_us_page')
      end
    end

    # Filtering

    describe 'Filtering coffees' do
      it 'filters coffees using search input' do
        fill_in 'search', with: 'Steffspresso'
        click_button 'Search'

        expect(page.status_code).to eq(200)
      end

      it 'filters coffees using roast dropdown' do
        select 'Medium Roast', from: 'roast'
        click_button 'Search'

        expect(page.status_code).to eq(200)
      end

      it 'clears the coffee filters' do
        click_button 'Clear'

        expect(page.status_code).to eq(200)
      end
    end

    # Basket

    describe 'Basket sidebar' do
      it 'shows the basket quantity badge' do
        expect(page).to have_css('.basket-count-badge')
      end

      it 'shows quantity buttons if basket items exist' do
        expect(page.body).to satisfy do |body|
          body.include?('qty-btn') || body.include?('Checkout')
        end
      end
    end
  end
end