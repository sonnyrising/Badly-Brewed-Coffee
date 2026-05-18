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
    Email: 'buyer@example.com',
    PassHash: BCrypt::Password.create('Password123!'),
    LoyaltyPoints: 0,
    Suspended: 0,
    DateJoined: '01/01/2026'
  )
  
  visit '/login'
  fill_in 'uname', with: username
  fill_in 'pword', with: 'Password123!'
  click_button 'Log in'
  user
end

RSpec.describe 'User Order History Flow', type: :feature do
  before(:each) do
    Users.dataset.delete
    Products.dataset.delete
    Transactions.dataset.delete
    Basket.dataset.delete
    
    @user = login_as_test_user('coffee_buyer')
  end

  # -------------------------------------------------------------------------
  # No Order History
  # -------------------------------------------------------------------------
  context 'when a new user has no past purchases' do
    it 'displays a  message matching the layout state' do
      visit '/user/orders'

      expect(page.status_code).to eq(200)
      expect(page).to have_content('Recent Transactions')
      expect(page).to have_content('No recent transactions found.')
    end
  end

  # -------------------------------------------------------------------------
  # Populated Transactions Table
  # -------------------------------------------------------------------------
  context 'when a user has recent purchases' do
    it 'renders a table of the transaction items' do
      coffee = Products.create(
        ProductName: 'Espresso Blend',
        Price: 3.50,
        Bean: true,
        StockQuantity: 100
      )

      transaction = Transactions.create(
        UserId: @user.UserId,
        TotalCost: 7.00,
        TransactionDate: '18052026'
      )

      Basket.create(
        UserId: @user.UserId,
        ProductId: coffee.ProductId,
        Quantity: 2,
        TransactionId: transaction.TransactionId
      )

      visit '/user/orders'

      expect(page.status_code).to eq(200)
      expect(page).to have_content('Recent Transactions')      
      expect(page).to have_content('18/05/2026')
      expect(page).to have_content('£7.00')
      expect(page).to have_content('Espresso Blend')
      expect(page).to have_content('2')
    end
  end
end