require 'capybara/rspec'
require 'rack/test'

require_relative '../spec_helper'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_manager
  visit '/login'
  fill_in 'uname', with: 'manager'
  fill_in 'pword', with: 'manager'
  click_button 'Log in'
end

RSpec.describe 'Manage Stock Page', type: :feature do

  before(:each) do
    login_as_manager
    visit '/managestock'
  end

  # -------------------------------------------------------------------------
  # Page load
  # -------------------------------------------------------------------------

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'displays the Manage Stock heading' do
      expect(page).to have_content('Manage Stock')
    end

    it 'renders a product card for each product in the database' do
      expect(page.all('.product-box').length).to eq(Products.count + 1)
    end

    it 'renders the add product button' do
      expect(page).to have_link(href: '/addproduct')
    end
  end

  # -------------------------------------------------------------------------
  # Sidebar navigation
  # -------------------------------------------------------------------------

  describe 'Sidebar navigation' do
    it 'shows the View Dashboard button for a manager' do
      expect(page).to have_link('View Dashboard')
    end

    it 'navigates to the manager dashboard when View Dashboard is clicked' do
      click_link 'View Dashboard'
      expect(page).to have_current_path('/manager/homepage')
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
  # Product cards
  # -------------------------------------------------------------------------

  describe 'Product cards' do
    it 'pre-populates the product name field' do
      first_card = page.first('.product-box')
      expect(first_card.find('input[name="product_name"]').value).not_to be_empty
    end

    it 'pre-populates the stock quantity field' do
      first_card = page.first('.product-box')
      expect(first_card.find('input[name="product_stock"]').value).to match(/\A\d+/)
    end

    it 'pre-populates the price field' do
      first_card = page.first('.product-box')
      expect(first_card.find('input[name="product_price"]').value).to match(/\A\d+/)
    end

    it 'pre-populates the type field with Coffee or Bean' do
      first_card = page.first('.product-box')
      expect(first_card.find('input[name="product_type"]').value).to match(/\A(Coffee|Bean)\z/)
    end

    it 'pre-populates the roast field' do
      first_card = page.first('.product-box')
      expect(first_card.find('input[name="product_roast"]').value).not_to be_empty
    end

    it 'pre-populates the origin field' do
      first_card = page.first('.product-box')
      expect(first_card.find('input[name="product_origin"]').value).not_to be_empty
    end

    it 'renders a Save Changes button on each product card' do
      page.all('.product-box')[0..-2].each do |card|
        expect(card).to have_button('Save Changes')
      end
    end

    it 'renders a Delete Product button on each product card' do
      page.all('.product-box')[0..-2].each do |card|
        expect(card).to have_button('Delete Product')
      end
    end
  end

  # -------------------------------------------------------------------------
  # Updating a product
  # -------------------------------------------------------------------------

  describe 'Updating a product' do
    def first_product_card
      page.first('.product-box')
    end

    it 'redirects back to managestock after a valid update' do
      first_product_card.find('input[name="product_name"]').set('Updated Coffee')
      page.driver.post(
        '/updatestock',
        product_id: Products.first.ProductId,
        product_name: 'Updated Coffee',
        product_stock: '10',
        product_price: '5.00',
        product_image: 'old.jpg',
        product_description: 'Old desc',
        product_origin: 'Brazil',
        product_roast: 'Medium',
        product_type: 'Coffee'
      )
      visit '/managestock'
      expect(page).to have_current_path('/managestock')
      expect(page).to have_css('input[value="Updated Coffee"]')
    end

    it 'shows an error alert for an invalid product name' do
      visit '/managestock?error=invalid_name'
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product name.')
    end

    it 'shows an error alert for an invalid stock quantity' do
      visit '/managestock?error=invalid_stock'
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid stock quantity.')
    end

    it 'shows an error alert for an invalid price' do
      visit '/managestock?error=invalid_price'
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid price.')
    end

    it 'shows an error alert for an invalid product type' do
      visit '/managestock?error=invalid_type'
      expect(page).to have_css('.alert-banner')
      expect(page).to have_content('Please enter a valid product type (Bean or Coffee).')
    end
  end

  # -------------------------------------------------------------------------
  # Deleting a product
  # -------------------------------------------------------------------------

  describe 'Deleting a product' do
    it 'removes the product from the page after deletion' do
      product_id = Products.first.ProductId
      count_before = Products.count

      page.driver.post('/deleteproduct', product_id: product_id)
      visit '/managestock'

      expect(Products.count).to eq(count_before - 1)
      expect(page.all('.product-box').length).to eq(Products.count + 1)
    end

    it 'redirects back to managestock after deletion' do
      page.driver.post('/deleteproduct', product_id: Products.first.ProductId)
      visit '/managestock'
      expect(page).to have_current_path('/managestock')
    end
  end

  # -------------------------------------------------------------------------
  # Adding a product
  # -------------------------------------------------------------------------

  describe 'Adding a product' do
    it 'navigates to the add product page when the + box is clicked' do
      click_link href: '/addproduct'
      expect(page).to have_current_path('/addproduct')
    end
  end

  # -------------------------------------------------------------------------
  # Access control
  # -------------------------------------------------------------------------

  describe 'Access control' do
    context 'when visiting without any session' do
      before do
        Capybara.reset_sessions!
        visit '/managestock'
      end

      it 'redirects away from the manage stock page' do
        expect(page.current_path).not_to eq('/managestock')
      end
    end
  end
end