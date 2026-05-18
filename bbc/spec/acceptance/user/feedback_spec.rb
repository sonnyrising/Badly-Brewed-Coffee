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
    Email: 'help_test@example.com',
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

RSpec.describe 'User Support Feedback Flow', type: :feature do
  before(:each) do
    Feedbacks.dataset.delete if defined?(Feedbacks)
    Transactions.dataset.delete
    Users.dataset.delete
    
    @user = login_as_test_user('help_seeker')
  end

  #Standard Issue Report (No Refund)
  context 'when submitting a general  report' do
    it 'displays a note confirming submission receipt' do
      Transactions.dataset.insert(
        TransactionId: 9501,
        UserId: @user.UserId,
        TotalCost: 5.00,
        TransactionDate: '18052026',
        Refunded: false,
        RefundRequested: false
      )

      visit '/user/contact_us_page'

      fill_in 'issue', with: 'The UI layout looks great on my screen.'
      choose 'no'
      fill_in 'reason', with: 'no'
      fill_in 'transaction_id', with: 9501
      click_button 'Submit'

      expect(page.status_code).to eq(200)
      expect(page).to have_content('Thank you for letting us know!')
    end
  end

  #Refund Request Form Interaction
  context 'when filing an active order refund request' do
    it 'submits the form data and handles the validation feedback block' do
      Transactions.dataset.insert(
        TransactionId: 9502,
        UserId: @user.UserId,
        TotalCost: 12.50,
        TransactionDate: '18052026',
        Refunded: false,
        RefundRequested: false
      )

      visit '/user/contact_us_page'

      fill_in 'issue', with: 'The package was missing items.'
      choose 'yes'
      fill_in 'reason', with: 'Missing two bags of coffee beans.'
      fill_in 'transaction_id', with: 9502
      click_button 'Submit'

      expect(page.status_code).to eq(200)
      expect(page).to have_content('BBC Help Page')
    end
  end

  #Validation Error Handling
  context 'when entering an invalid transaction ID' do
    it 'halts submission processing and flashes an error warning alert' do
      visit '/user/contact_us_page'

      fill_in 'issue', with: 'I would like a refund.'
      choose 'yes'
      fill_in 'reason', with: 'Item never arrived.'
      fill_in 'transaction_id', with: 999999
      click_button 'Submit'

      expect(page).to have_content('Transaction ID not found. Please try again!')
    end
  end
end