# frozen_string_literal: true

require 'capybara/rspec'
require 'rack/test'

require_relative '../spec_helper'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_manager
  visit '/login'
  fill_in 'username', with: 'Manager123!'
  fill_in 'password', with: 'Manager123!'
  click_button 'Log in'
end

RSpec.describe 'Add Product Page', type: :feature do
  before(:each) do
    login_as_manager
    visit '/addproduct'
  end

  # -------------------------------------------------------------------------
  # Page load
  # -------------------------------------------------------------------------

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'displays the Product Details heading' do
      expect(page).to have_content('Product Details')
    end

    it 'renders all input fields' do
      expect(page).to have_css('input[name="product_name"]')
      expect(page).to have_css('input[name="product_stock"]')
      expect(page).to have_css('input[name="product_price"]')
      expect(page).to have_css('input[name="product_roast"]')
      expect(page).to have_css('input[name="product_origin"]')
      expect(page).to have_css('input[name="product_description"]')
      expect(page).to have_css('input[name="product_image"]')
    end

    it 'renders the Save Changes button' do
      expect(page).to have_button('Save Changes')
    end
  end

  # -------------------------------------------------------------------------
  # Sidebar navigation
  # -------------------------------------------------------------------------

  describe 'Sidebar navigation' do
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
  # Helpers
  # -------------------------------------------------------------------------

  def fill_in_product(overrides = {})
    defaults = {
      'product_name' => 'Test Coffee',
      'product_stock' => '10',
      'product_price' => '3.50',
      'product_roast' => 'Medium',
      'product_origin' => 'Brazil',
      'product_description' => 'A test coffee',
      'product_image' => 'test.jpg',
      'product_type' => 'Coffee'
    }
    fields = defaults.merge(overrides.transform_keys(&:to_s))

    page.driver.post('/addproduct', fields)
    redirect_to = page.driver.response.headers['Location'] || '/managestock'
    visit redirect_to
  end

  # -------------------------------------------------------------------------
  # Valid submissions
  # -------------------------------------------------------------------------

  describe 'Valid submissions' do
    it 'adds a Coffee product and redirects to managestock' do
      count_before = Products.count
      fill_in_product
      expect(Products.count).to eq(count_before + 1)
      expect(page).to have_current_path('/managestock')
    end

    it 'adds a Bean product successfully' do
      count_before = Products.count
      fill_in_product(product_name: 'Test Bean', product_type: 'Bean')
      expect(Products.count).to eq(count_before + 1)
    end

    it 'stores the correct product name in the database' do
      fill_in_product(product_name: 'Unique Name Coffee')
      expect(page).to have_css("input[value='Unique Name Coffee']")
    end

    it 'accepts a stock value of 1 (minimum valid integer)' do
      count_before = Products.count
      fill_in_product(product_stock: '1')
      expect(Products.count).to eq(count_before + 1)
    end

    it 'accepts a price with two decimal places' do
      count_before = Products.count
      fill_in_product(product_price: '9.99')
      expect(Products.count).to eq(count_before + 1)
    end

    it 'accepts a whole number price' do
      count_before = Products.count
      fill_in_product(product_price: '5')
      expect(Products.count).to eq(count_before + 1)
    end
  end

  # -------------------------------------------------------------------------
  # Invalid name
  # -------------------------------------------------------------------------

  describe 'Invalid product name' do
    it 'rejects an empty name and shows an error' do
      fill_in_product(product_name: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product name.')
    end

    it 'rejects a name containing single quotes' do
      fill_in_product(product_name: "O'Brien's")
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product name.')
    end

    it 'rejects a name containing double quotes' do
      fill_in_product(product_name: '"Special"')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product name.')
    end

    it 'rejects a name containing a semicolon' do
      fill_in_product(product_name: 'Coffee; DROP TABLE')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product name.')
    end

    it 'rejects a name containing an equals sign' do
      fill_in_product(product_name: 'name=value')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product name.')
    end

    it 'does not add the product to the database on an invalid name' do
      count_before = Products.count
      fill_in_product(product_name: '')
      expect(Products.count).to eq(count_before)
    end
  end

  # -------------------------------------------------------------------------
  # Invalid stock
  # -------------------------------------------------------------------------

  describe 'Invalid stock quantity' do
    it 'rejects an empty stock value and shows an error' do
      fill_in_product(product_stock: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid stock quantity.')
    end

    it 'rejects a stock value of 0' do
      fill_in_product(product_stock: '0')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid stock quantity.')
    end

    it 'rejects a negative stock value' do
      fill_in_product(product_stock: '-1')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid stock quantity.')
    end

    it 'rejects a decimal stock value' do
      fill_in_product(product_stock: '2.5')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid stock quantity.')
    end

    it 'rejects a non-numeric stock value' do
      fill_in_product(product_stock: 'lots')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid stock quantity.')
    end

    it 'does not add the product to the database on invalid stock' do
      count_before = Products.count
      fill_in_product(product_stock: '0')
      expect(Products.count).to eq(count_before)
    end
  end

  # -------------------------------------------------------------------------
  # Invalid price
  # -------------------------------------------------------------------------

  describe 'Invalid price' do
    it 'rejects an empty price and shows an error' do
      fill_in_product(product_price: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid price.')
    end

    it 'rejects a price of 0' do
      fill_in_product(product_price: '0')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid price.')
    end

    it 'rejects a negative price' do
      fill_in_product(product_price: '-1.00')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid price.')
    end

    it 'rejects a non-numeric price' do
      fill_in_product(product_price: 'free')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid price.')
    end

    it 'does not add the product to the database on invalid price' do
      count_before = Products.count
      fill_in_product(product_price: '0')
      expect(Products.count).to eq(count_before)
    end
  end

  # -------------------------------------------------------------------------
  # Invalid type
  # -------------------------------------------------------------------------

  describe 'Invalid product type' do
    it 'rejects a type that is neither Coffee nor Bean' do
      fill_in_product(product_type: 'Tea')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product type (Bean or Coffee).')
    end

    it 'rejects an empty type' do
      fill_in_product(product_type: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product type (Bean or Coffee).')
    end

    it 'rejects a type with incorrect casing' do
      fill_in_product(product_type: 'coffee')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product type (Bean or Coffee).')
    end

    it 'does not add the product to the database on invalid type' do
      count_before = Products.count
      fill_in_product(product_type: 'Tea')
      expect(Products.count).to eq(count_before)
    end
  end

  # -------------------------------------------------------------------------
  # Invalid optional string fields
  # -------------------------------------------------------------------------

  describe 'Invalid optional fields' do
    it 'rejects an empty roast and shows an error' do
      fill_in_product(product_roast: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid roast.')
    end

    it 'rejects an empty origin and shows an error' do
      fill_in_product(product_origin: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid origin.')
    end

    it 'rejects an empty description and shows an error' do
      fill_in_product(product_description: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid description.')
    end

    it 'rejects an empty image and shows an error' do
      fill_in_product(product_image: '')
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid image URL.')
    end
  end

  # -------------------------------------------------------------------------
  # Access control
  # -------------------------------------------------------------------------

  describe 'Access control' do
    context 'when visiting without any session' do
      before do
        Capybara.reset_sessions!
        visit '/addproduct'
      end

      it 'redirects away from the add product page' do
        expect(page.current_path).not_to eq('/addproduct')
      end
    end
  end
end
